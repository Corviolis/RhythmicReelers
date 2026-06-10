class_name PathfindingComponent
extends NavigationAgent2D

signal velocity_updated(velocity: Vector2)

@export var body: CharacterBody2D
@export var movement_component: MovementComponent

var speed: float


func set_target(location: Vector2) -> void:
	target_position = location


func _on_velocity_computed(vel: Vector2) -> void:
	velocity_updated.emit(vel)


func _on_navigation_finished() -> void:
	velocity_updated.emit(Vector2.ZERO)


func _physics_process(_delta: float) -> void:
	if not is_navigation_finished():
		var next_path_pos := get_next_path_position()
		var direction := body.global_position.direction_to(next_path_pos)
		velocity = movement_component.speed * direction
