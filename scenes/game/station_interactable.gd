extends Node2D

var outline_color: Vector3

@onready var interaction_area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_outline_color(color: Vector3) -> void:
	sprite.material.set_shader_parameter("outline_color", Vector4(color.x, color.y, color.z, 1.0))

func hide_outline() -> void:
	sprite.material.set_shader_parameter("outline_color", Vector4(0, 0, 0, 0))

func show_outline() -> void:
	sprite.material.set_shader_parameter("outline_color", Vector4(outline_color.x, outline_color.y, outline_color.z, 1.0))
