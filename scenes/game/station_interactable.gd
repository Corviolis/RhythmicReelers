class_name StationInteractable
extends Node2D

@export var minigame: WindowManager.Minigames

var nearby_players: Array[Player] = []
var occupied: bool = false

@onready var interaction_area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

signal free_station
signal occupy_station


func _ready() -> void:
	free_station.connect(_on_free_station)


func calculate_color() -> Color:
	var nearby_player_count := nearby_players.size()
	if nearby_player_count == 0:
		return Color.TRANSPARENT
	if nearby_player_count == 1:
		return nearby_players[0].color
	return Color.WHITE


func set_outline_color(color: Color) -> void:
	sprite.material.set_shader_parameter("outline_color", color)


func add_nearby_player(player: Player) -> void:
	nearby_players.append(player)
	set_outline_color(calculate_color())


func remove_nearby_player(player: Player) -> void:
	nearby_players.erase(player)
	set_outline_color(calculate_color())


# TODO: don't allow a second player to join the station
func interact(player_id: int) -> void:
	if occupied:
		return
	PlayerManager.start_player_minigame(player_id)
	WindowManager.create_window.rpc(position, minigame, player_id, occupy_station, free_station)


func _on_free_station():
	print("free")
	occupied = false


func _on_occupy_station():
	print("occupied")
	occupied = true
