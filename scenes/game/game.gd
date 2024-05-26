extends Node2D

var player_scene = load("res://scenes/game/player.tscn") as Resource
@onready var boat = $Boat as StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.server_disconnected.connect(_error_to_lobby)
	_create_players()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _go_to_lobby():
	GlobalUtils.goto_scene(^"res://scenes/lobby/lobby.tscn")

func _error_to_lobby():
	PlayerManager.drop_all_players()
	_go_to_lobby()

func _create_players():
	for player_index in PlayerManager.get_player_indexes():
		var char_index = PlayerManager.get_player_data(player_index, "character_index") as int
		var device = PlayerManager.get_player_device(player_index)
		var player = player_scene.instantiate() as Player
		var player_sprite = player.get_node(^"Sprite2D") as Sprite2D
		player.set_multiplayer_authority(PlayerManager.get_player_authority(player_index))
		player.set_device(device)
		player.name = str(player_index)
		player_sprite.texture = PlayerManager.get_character_assets(char_index)["idle.png"]
		boat.add_child(player)