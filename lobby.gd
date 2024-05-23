extends Control

var player_card_scene = load("res://player_card.tscn") as Resource
@onready var lobby_list = $LobbyList as HBoxContainer
@onready var player_list = $PlayerList as HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(player_connected)
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
	NetworkManager.host_game()

func join_game():
	NetworkManager.join_game($ServerIP.text)

func player_connected(id: int):
	print("Recieved connection from %d" % id)
	var player_label := Label.new()
	player_label.text = str(id)
	lobby_list.add_child(player_label)

	# allow late players to see the current player list
	if multiplayer.is_server():
		for player in PlayerManager.get_player_indexes():
			PlayerManager.join_game_puppet.rpc_id(id, player, -2 if (PlayerManager.get_player_device(player) == -1) else -3)
			
