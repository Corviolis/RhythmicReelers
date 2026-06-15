class_name AttackSpot
extends Area2D

signal covered

var occupied: bool
var overlapping_areas: int = 0
var is_available: bool:
	get:
		return overlapping_areas <= 0 and not occupied


func _on_window_entered(_area: Area2D) -> void:
	overlapping_areas += 1
	covered.emit()


func _on_window_exited(_area: Area2D) -> void:
	overlapping_areas -= 1


func add_occupant() -> void:
	occupied = true


func remove_occupant() -> void:
	occupied = false
