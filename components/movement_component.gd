class_name MovementComponent
extends Node

var velocity: Vector2

@export var body: CharacterBody2D
@export var pathfinding_component: PathfindingComponent

@export var speed: float = 10


func _on_pathfinding_velocity_updated(vel_in: Vector2) -> void:
	velocity = vel_in


func _physics_process(_delta: float) -> void:
	body.velocity = body.velocity.move_toward(velocity, 5)
	body.move_and_slide()
