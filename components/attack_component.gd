class_name AttackComponent
extends Node

signal attack
signal left_attack_range

@onready var attack_cooldown: Timer = $AttackCooldown


func _on_range_body_exited(_body: Node2D) -> void:
	left_attack_range.emit()
	attack_cooldown.stop()


func _attack() -> void:
	attack.emit()
	attack_cooldown.start()
	print("attack")


func start_attacking() -> void:
	attack_cooldown.start()
