extends Node2D

@export var attack_component: AttackComponent


func _physics_process(_delta: float) -> void:
	attack_component.attack()
	await get_tree().physics_frame
	queue_free()
