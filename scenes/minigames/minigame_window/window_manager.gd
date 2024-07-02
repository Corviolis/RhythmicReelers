class_name WindowManager
extends Node

enum Minigames {
	Fishing,
	Cutting,
	Packaging
}

var window_scene = load("res://scenes/minigames/minigame_window/minigame_window.tscn") as PackedScene
var windows: Array[StaticBody2D] = []

func load_minigame(minigame: Minigames) -> PackedScene:
	match minigame:
		Minigames.Fishing:
			return load("res://scenes/minigames/fishing/fishing.tscn")
		_:
			push_error("No minigame scene provided for " + Minigames.keys()[minigame])
			return load("")

func calculate_position(initial_position: Vector2) -> Vector2:
	return Vector2.ZERO

func create_window(initial_position: Vector2, minigame: Minigames):
	var minigame_window = window_scene.instantiate() as MinigameWindow
	add_child(minigame_window)
	var window_position = calculate_position(initial_position)
	minigame_window.place_window(window_position, 40, 70, load_minigame(minigame))