extends CharacterBody2D

enum States { MOVING, ATTACKING }
var current_state := States.MOVING

@onready var pathfinding_component: PathfindingComponent = %PathfindingComponent
@onready var boat: Node2D = get_parent().get_parent().get_child(0)


func _ready() -> void:
	pathfinding_component.set_target(_get_pathfinding_target())


func _process(_delta: float) -> void:
	pass


func _get_pathfinding_target() -> Vector2:
	return boat.position
