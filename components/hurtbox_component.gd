class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent

signal got_hit


func take_hit(damage: int) -> void:
	got_hit.emit()
	health_component.take_damage(damage)
