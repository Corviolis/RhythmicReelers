class_name AttackComponent
extends Area2D

signal on_attack
signal left_attack_range

@export var damage: int = 1

var is_in_range: bool:
	get:
		return has_overlapping_areas()


func _on_range_exited(_body: Area2D) -> void:
	left_attack_range.emit()


func attack() -> void:
	on_attack.emit()
	var hurtboxes_hit: Array[HurtboxComponent]
	hurtboxes_hit.assign(get_overlapping_areas())
	for hurtbox_component: HurtboxComponent in hurtboxes_hit:
		hurtbox_component.take_hit(damage)
