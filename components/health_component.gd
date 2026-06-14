class_name HealthComponent
extends Node

@export var max_health: int = 1
@export var health: int = 1:
	set(value):
		health = clampi(value, 0, max_health)

signal health_changed(health: int, max_health: int)
signal died


func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	if health == 0:
		died.emit()
		print("died")


func heal(amount: int) -> void:
	health += amount
	health_changed.emit(health, max_health)
