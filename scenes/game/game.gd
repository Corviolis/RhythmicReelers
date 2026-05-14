class_name Game
extends Node2D

var player_scene = load("res://scenes/game/player.tscn") as PackedScene
var raw_fish: int = 0
var cut_fish: int = 0

@onready var boat = $Boat as StaticBody2D
@onready var resources = $Control/Resources as Label


func _ready():
	multiplayer.server_disconnected.connect(_error_to_lobby)
	_create_players()
	resources.text = "FISH: %s\nCUT: %s" % [raw_fish, cut_fish]


func add_raw_fish(count: int):
	raw_fish += count
	resources.text = "FISH: %s\nCUT: %s" % [raw_fish, cut_fish]


func add_cut_fish(count: int):
	if raw_fish <= 0:
		return
	raw_fish -= count
	cut_fish += count
	resources.text = "FISH: %s\nCUT: %s" % [raw_fish, cut_fish]


func _go_to_lobby():
	GlobalUtils.goto_scene(^"res://scenes/lobby/lobby.tscn")


func _error_to_lobby():
	PlayerManager.drop_all_players()
	_go_to_lobby()


func _create_players():
	for player_index in PlayerManager.get_player_indexes():
		var char_index := PlayerManager.get_player_data(player_index, "character_index") as int
		var device: int = PlayerManager.get_player_device(player_index)
		var player := player_scene.instantiate() as Player
		var player_sprite := player.get_node(^"Sprite2D") as Sprite2D
		player.set_multiplayer_authority(PlayerManager.get_player_authority(player_index))
		player.set_device(device)
		player.player_id = player_index
		player.name = str(player_index)
		player_sprite.texture = PlayerManager.get_character_assets(char_index)["idle.png"]
		player_sprite.material = PlayerManager.get_character_assets(char_index)["material.tres"]
		boat.add_child(player)
