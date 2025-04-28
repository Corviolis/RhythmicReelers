class_name Lobby
extends Control

var player_card_scene = load("res://scenes/lobby/player_card.tscn") as Resource
var available_icons: Array[bool] = [true]
@onready var lobby_list = $LobbyList as HBoxContainer
@onready var player_list = $PlayerList as HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	PlayerManager.player_joined.connect(add_player)
	PlayerManager.player_left.connect(delete_player)

	available_icons.resize(PlayerManager.get_character_asset_count())
	for i in range(0, PlayerManager.get_character_asset_count()):
		available_icons[i] = true

	RhythmEngine.play_song("demo_song")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	PlayerManager.handle_join_input()


func add_player(player: int, authority: int):
	PlayerManager.set_player_data(player, &"multiplayer_authority", authority)
	var player_card = player_card_scene.instantiate() as PlayerCard
	player_card.set_multiplayer_authority(authority)
	player_card.name = StringName(str(player))
	player_list.add_child(player_card)
	player_card.init(player)


func delete_player(player: int):
	var player_card := player_list.get_node(str(player))
	available_icons[player_card.char_index] = true
	player_card.queue_free()


func host_game():
	$Buttons/OpenServer.disabled = true
	$Buttons/JoinServer.disabled = true
	$Buttons/LeaveServer.disabled = false
	NetworkManager.host_game()


func join_game():
	$Buttons/OpenServer.disabled = true
	$Buttons/JoinServer.disabled = true
	$Buttons/StartGame.disabled = true
	$Buttons/LeaveServer.disabled = false
	NetworkManager.join_game($Buttons/ServerIP.text)


func start_game():
	GlobalUtils.goto_scene.rpc("res://scenes/game/game.tscn")


func leave_server():
	NetworkManager.leave_server()
	PlayerManager.drop_all_players()
	for node in lobby_list.get_children():
		if node.name != &"Label":
			node.queue_free()
	$Buttons/OpenServer.disabled = false
	$Buttons/JoinServer.disabled = false
	$Buttons/StartGame.disabled = false
	$Buttons/LeaveServer.disabled = true


func player_connected(id: int):
	print("Recieved connection from %d" % id)
	var player_label := Label.new()
	player_label.text = str(id)
	player_label.name = str(id)
	player_label.use_parent_material = true
	lobby_list.add_child(player_label)

	# allow late players to see the current player list
	if multiplayer.is_server():
		for player in PlayerManager.get_player_indexes():
			PlayerManager.create_empty_player.rpc_id(
				id,
				player,
				(
					-2
					if (
						PlayerManager.get_player_device(player) == -1
						or PlayerManager.get_player_device(player == -2)
					)
					else -3
				),
				PlayerManager.get_player_data(player, "character_index"),
				PlayerManager.get_player_authority(player)
			)


func player_disconnected(id: int):
	var player_label = lobby_list.get_node(str(id))
	player_label.queue_free()
