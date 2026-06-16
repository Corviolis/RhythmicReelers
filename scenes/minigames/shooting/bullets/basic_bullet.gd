extends Node2D

@export var attack_component: AttackComponent


func _physics_process(_delta: float) -> void:
	await get_tree().physics_frame
	attack_component.attack()
	queue_free()
