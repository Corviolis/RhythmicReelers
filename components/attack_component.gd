class_name AttackComponent
extends Node

signal attack
signal left_attack_range

@export var damage: int = 1

var is_in_range: bool:
	get:
		return hitbox.has_overlapping_areas()

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var hitbox: Area2D = $Hitbox


func _on_range_exited(_body: Area2D) -> void:
	left_attack_range.emit()
	stop_attacking()


func _attack() -> void:
	attack.emit()
	attack_cooldown.start()
	var hurtboxes_hit: Array[HurtboxComponent]
	hurtboxes_hit.assign(hitbox.get_overlapping_areas())
	for hurtbox_component: HurtboxComponent in hurtboxes_hit:
		hurtbox_component.take_hit(damage)


func start_attacking() -> void:
	attack_cooldown.start()


func stop_attacking() -> void:
	attack_cooldown.stop()
