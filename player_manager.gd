extends Node

# player is 0-3
# device is -1 for keyboard/mouse, 0+ for joypads
# these concepts seem similar but it is useful to separate them so for example, device 6 could control player 1.

signal player_joined(player: int, authority: int)
signal player_left(player: int)

# map from player integer to dictionary of data
# the existence of a key in this dictionary means this player is joined.
# use get_player_data() and set_player_data() to use this dictionary.
var player_data: Dictionary = {}
var character_assets: Array[Dictionary]

const MAX_PLAYERS = 4

func _ready():
	var chars_dir = DirAccess.open("res://characters")
	chars_dir.list_dir_begin()
	var folder = chars_dir.get_next()
	
	while folder != "":
		var assets = {}
		var char_dir = DirAccess.open("res://characters/" + folder)
		char_dir.list_dir_begin()
		var asset = char_dir.get_next()
		
		while asset != "" && asset.ends_with(".png"):
			assets[asset] = load("res://characters/" + folder + "/" + asset)
			asset = char_dir.get_next()
		
		character_assets.append(assets)
		folder = chars_dir.get_next()

func get_character_asset_count():
	return character_assets.size()

func get_character_assets(index: int):
	return character_assets[index]

# called by the server after verifying that a player spot exists
# or called locally if not multiplayer (or if server)
@rpc("call_local", "reliable")
func join_game(device: int, player: int):
	join_game_puppet.rpc(player, -2 if (device == -1) else -3)
	if player >= 0:
		# initialize default player data here
		player_data[player] = {
			"device": device,
		}
		player_joined.emit(player, multiplayer.get_unique_id())

func join(device: int):
	var player: int
	if NetworkManager.is_multiplayer:
		next_player_rpc.rpc_id(1, device)
		return
	player = next_player()
	join_game(device, player)

# creates a 'fake' player on remote clients (including the server if we are not the server)
# the device here is just to make the controller / keyboard icon work (feeling cute might remove later)
# device -2 = keyboard, -3 = controller
@rpc("any_peer", "reliable")
func join_game_puppet(player: int, device: int):
	if player >= 0:
		# initialize default player data here
		player_data[player] = {
			"device": device
		}
		player_joined.emit(player, multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_local", "reliable")
func leave(player: int):
	if player_data.has(player):
		player_data.erase(player)
		player_left.emit(player)

func drop_all_players():
	for player in get_player_indexes():
		leave(player)

func get_player_count():
	return player_data.size()

func get_player_indexes():
	return player_data.keys()

func get_player_device(player: int) -> int:
	return get_player_data(player, "device")

# get player data.
# null means it doesn't exist.
func get_player_data(player: int, key: StringName):
	if player_data.has(player) and player_data[player].has(key):
		return player_data[player][key]
	printerr("Failure when trying to access key [%s] on player [%d]" % [key, player])
	return null

# set player data to get later
func set_player_data(player: int, key: StringName, value: Variant):
	# if this player is not joined, don't do anything:
	if !player_data.has(player):
		return
	
	player_data[player][key] = value

# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices
func handle_join_input():
	for device in get_unjoined_devices():
		# for testing controller (TODO remember to remove after game is done)
		# if device == -1 or multiplayer.is_server():
		if MultiplayerInput.is_action_just_pressed(device, &"join"):
			join(device)

# to see if anybody is pressing the "start" action
# this is an example of how to look for an action on all players
# note the difference between this and handle_join_input(). players vs devices.
func someone_wants_to_start() -> bool:
	for player in player_data:
		var device = get_player_device(player)
		if MultiplayerInput.is_action_just_pressed(device, "start"):
			return true
	return false

func is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = get_player_device(player_id)
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	for i in MAX_PLAYERS:
		if !player_data.has(i): return i
	return -1

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
@rpc("any_peer", "call_local", "reliable")
func next_player_rpc(device:int):
	for i in MAX_PLAYERS:
		if !player_data.has(i): 
			join_game.rpc_id(multiplayer.get_remote_sender_id(), device, i)
			return
	join_game.rpc_id(multiplayer.get_remote_sender_id(), device, -1)

# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
