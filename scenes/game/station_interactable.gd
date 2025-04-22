class_name StationInteractable
extends Node2D

var nearby_players: Array[Player] = []

@export var minigame: WindowManager.Minigames

@onready var window_manager := get_node("/root/Game/WindowManager") as WindowManager
@onready var interaction_area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	pass


func calculate_color() -> Color:
	var nearby_player_count := nearby_players.size()
	if nearby_player_count == 0:
		return Color.TRANSPARENT
	elif nearby_player_count == 1:
		return nearby_players[0].color
	else:
		return Color.WHITE


func set_outline_color(color: Color) -> void:
	sprite.material.set_shader_parameter("outline_color", color)


func add_nearby_player(player: Player) -> void:
	nearby_players.append(player)
	set_outline_color(calculate_color())


func remove_nearby_player(player: Player) -> void:
	nearby_players.erase(player)
	set_outline_color(calculate_color())


func interact(player: Player) -> void:
	window_manager.create_window.rpc(position, minigame, player)
