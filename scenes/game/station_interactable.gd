extends Node2D

var nearby_players: Array[Player] = []

@onready var interaction_area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.body_entered.connect(body_entered)
	interaction_area.body_exited.connect(body_exited)


func body_entered(player: Player) -> void:
	nearby_players.append(player)
	set_outline_color(calculate_color())


func body_exited(player: Player) -> void:
	nearby_players.erase(player)
	set_outline_color(calculate_color())


func calculate_color() -> Color:
	var nearby_player_count := nearby_players.size()
	if nearby_player_count == 0:
		return Color.TRANSPARENT
	elif nearby_player_count == 1:
		return nearby_players[0].color
	else:
		return Color.WHITE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_outline_color(color: Color) -> void:
	sprite.material.set_shader_parameter("outline_color", color)
