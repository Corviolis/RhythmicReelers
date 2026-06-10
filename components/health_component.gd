extends Node

@export var max_health: int = 2
@export var health: int = 2:
	set(value):
		return clampi(value, 0, max_health)

signal health_changed(amount: int)
signal died


func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health)
	if health == 0:
		died.emit()


func heal(amount: int) -> void:
	health += amount
	health_changed.emit(health)
