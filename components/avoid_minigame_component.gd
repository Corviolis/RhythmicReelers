class_name AvoidMinigameComponent
extends Area2D

signal entered_window
signal left_window

var windows_inside: int = 0


func _on_area_exited(_area: Area2D) -> void:
	left_window.emit()
	windows_inside -= 1


func _on_area_entered(_area: Area2D) -> void:
	entered_window.emit()
	windows_inside += 1


func is_inside_window() -> bool:
	return windows_inside > 0
