extends Node

# player is 0-3
# device is -1 for keyboard/mouse, 0+ for joypads
# these concepts seem similar but it is useful to separate them so for example, device 6 could control player 1.

signal player_joined(player: int, authority: int)
signal player_left(player: int)

const MAX_PLAYERS = 4

# map from player integer to dictionary of data
# the existence of a key in this dictionary means this player is joined.
# use get_player_data() and set_player_data() to use this dictionary.
var player_data: Dictionary = {}
var character_assets: Array[Dictionary]

func _ready():
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.server_disconnected.connect(_server_closed)
	catalogue_player_assets()

#=== DATA MANAGEMENT ===

func get_character_asset_count():
	return character_assets.size()

func get_character_assets(index: int):
	return character_assets[index]

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

func catalogue_player_assets():
	var characters_directory = DirAccess.open("res://art/characters")
	characters_directory.list_dir_begin()
	var character_file = characters_directory.get_next() as String

	while character_file != "":
		var unit_assets = {}
		var character_path := DirAccess.open("res://art/characters/" + character_file)
		character_path.list_dir_begin()

		var asset = character_path.get_next() as String
		while asset != "" && asset.ends_with(".png"):
			unit_assets[asset] = load("res://art/characters/" + character_file + "/" + asset)
			asset = character_path.get_next()
		
		character_assets.append(unit_assets)
		character_file = characters_directory.get_next()

#=== LOCAL UTILITIES ===

@rpc("any_peer", "call_local", "reliable")
func leave(player: int):
	if player_data.has(player):
		player_data.erase(player)
		player_left.emit(player)

func drop_all_players():
	for player in get_player_indexes():
		leave(player)

# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices
func handle_join_input():
	for device in get_unjoined_devices():
		# for testing controller (TODO remember to remove after game is done)
		# if device == -1 or multiplayer.is_server():
		if MultiplayerInput.is_action_just_pressed(device, &"join"):
			_attempt_to_join(device)

# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	# filter out devices that are joined:
	return devices.filter(func(device): return !_is_device_joined(device))

# checks if the lobby is multiplayer
#	if it is request an open player spot from the server
#	else request an open player spot locally
func _attempt_to_join(device: int):
	if NetworkManager.is_multiplayer:
		_next_player_rpc.rpc_id(1, device)
		return
	_join_game(device, _next_player(), randi() % get_character_asset_count())

# called by the server after verifying that a player spot exists
# or called locally if not multiplayer (or if server)
@rpc("call_local", "reliable")
func _join_game(device: int, player: int, character_index: int):
	create_empty_player.rpc(player, -2 if (device == -1) else -3, character_index)
	if player >= 0:
		# initialize default player data here
		player_data[player] = {
			"device": device,
			"character_index": character_index
		}
		player_joined.emit(player, multiplayer.get_unique_id())

func _is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = get_player_device(player_id)
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func _next_player() -> int:
	for i in MAX_PLAYERS:
		if !player_data.has(i): return i
	return -1

#=== NETWORKING UTILITIES ===

# creates a 'fake' player on remote clients (including the server if we are not the server)
# the device here is just to make the controller / keyboard icon work (feeling cute might remove later)
#	lol who am I kidding it works so it will never be touched again
# device -2 = keyboard, -3 = controller
@rpc("any_peer", "reliable")
func create_empty_player(player: int, device: int, character_index: int, multiplayer_authority: int = multiplayer.get_remote_sender_id()):
	if player >= 0:
		# initialize default player data here
		player_data[player] = {
			"device": device,
			"character_index": character_index,
			"multiplayer_authority": multiplayer_authority
		}
		player_joined.emit(player, multiplayer_authority)

func get_player_authority(player: int) -> int:
	return get_player_data(player, "multiplayer_authority")

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
@rpc("any_peer", "call_local", "reliable")
func _next_player_rpc(device:int):
	var character_index = randi() % get_character_asset_count() as int
	for i in MAX_PLAYERS:
		if !player_data.has(i): 
			_join_game.rpc_id(multiplayer.get_remote_sender_id(), device, i, character_index)
			return
	_join_game.rpc_id(multiplayer.get_remote_sender_id(), device, -1, character_index)

#=== SIGNAL CALLBACKS ===

func _player_disconnected(id: int):
	for player in get_player_indexes():
		if get_player_authority(player) == id:
			leave(player)

func _server_closed():
	drop_all_players()
