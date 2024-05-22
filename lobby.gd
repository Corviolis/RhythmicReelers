extends Control

var player_card_scene = load("res://player_card.tscn") as Resource
@onready var lobby_list = $LobbyList as HBoxContainer
@onready var player_list = $PlayerList as HBoxContainer

var upnp: UPNP
var peer: ENetMultiplayerPeer
var port: int
var thread: Thread

const DEFAULT_PORT: int = 38426

func get_port() -> int:
	return port or DEFAULT_PORT

# TODO: add support to transition from multiplayer back to singleplayer
#		don't forget to clear the players again
# TODO: separate multiplayer resources and values into their own singleton

func setup_upnp():
	upnp = UPNP.new()
	var upnp_discover_result = upnp.discover() as int
	if upnp_discover_result == UPNP.UPNP_RESULT_SUCCESS and upnp.get_gateway().is_valid_gateway():
		var udp_mapping_result = upnp.add_port_mapping(get_port(), 0,
			ProjectSettings.get_setting("application/config/name") as String)
		if udp_mapping_result == UPNP.UPNP_RESULT_SUCCESS:
			print("UPNP Port Forward Succeeded")
		else:
			printerr("UPNP Port Forward Failed: %s" % udp_mapping_result)
		print(upnp.query_external_address())
	else:
		printerr("Gateway not discovered: %s" % upnp_discover_result)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(player_connected)
	thread = Thread.new()
	PlayerManager.player_joined.connect(add_player)
	PlayerManager.player_left.connect(delete_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	PlayerManager.handle_join_input()

func add_player(player: int, authority: int):
	var player_card := player_card_scene.instantiate() as PlayerCard
	player_card.set_multiplayer_authority(authority)
	player_card.init(player)
	player_card.name = StringName(str(player))
	player_card.get_node(^"PanelContainer/MarginContainer/VBoxContainer/PlayerName").text = "Player %d" % player
	player_list.add_child(player_card)

func delete_player(player: int):
	var player_card := player_list.get_node(str(player))
	player_list.remove_child(player_card)
	player_card.queue_free()

func host_game():
	thread.start(setup_upnp)
	peer = ENetMultiplayerPeer.new()
	peer.create_server(get_port(), 4)
	multiplayer.multiplayer_peer = peer
	PlayerManager.is_multiplayer = true

func join_game():
	PlayerManager.drop_all_players()
	peer = ENetMultiplayerPeer.new()
	peer.create_client($ServerIP.text, get_port())
	multiplayer.multiplayer_peer = peer
	PlayerManager.is_multiplayer = true

func player_connected(id: int):
	print("Recieved connection from %d" % id)
	var player_label := Label.new()
	player_label.text = str(id)
	lobby_list.add_child(player_label)

	# allow late players to see the current player list
	if multiplayer.is_server():
		for player in PlayerManager.get_player_indexes():
			PlayerManager.join_game_puppet.rpc_id(id, player, -2 if (PlayerManager.get_player_device(player) == -1) else -3)
			

func _exit_tree():
	thread.wait_to_finish()
