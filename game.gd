extends Node2D

var player_scene = load("res://player.tscn") as Resource
@onready var boat = $Boat as StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_players()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _create_players():
	for player_index in PlayerManager.get_player_indexes():
		var device = PlayerManager.get_player_device(player_index)
		var player = player_scene.instantiate() as Player
		player.set_multiplayer_authority(PlayerManager.get_player_authority(player_index))
		player.set_device(device)
		player.name = str(player_index)
		boat.add_child(player)
