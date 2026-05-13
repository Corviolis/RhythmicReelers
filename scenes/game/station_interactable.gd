class_name StationInteractable
extends Node2D

@export var minigame: WindowManager.Minigames

var nearby_players: Array[Player] = []
var occupied: bool = false

@onready var interaction_area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D


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


@rpc("any_peer", "call_local", "reliable")
func request_interact(player_id: int) -> void:
	if !multiplayer.is_server():
		return
	if occupied:
		return
	occupied = true
	open_minigame.bind(player_id).rpc_id(multiplayer.get_remote_sender_id())


@rpc("any_peer", "call_local", "reliable")
func close_interact(_player_id: int) -> void:
	if !multiplayer.is_server():
		return
	occupied = false


@rpc("authority", "call_local", "reliable")
func open_minigame(player_id: int):
	PlayerManager.start_player_minigame(player_id)
	WindowManager.create_window.rpc(position, minigame, player_id)


func interact(player_id: int) -> void:
	print(player_id)
	request_interact.bind(player_id).rpc_id(1)
