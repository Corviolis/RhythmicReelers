class_name WindowManager
extends Node

enum Minigames {
	Fishing,
	Cutting,
	Packaging
}

var window_scene = load("res://scenes/minigames/minigame_window/minigame_window.tscn") as PackedScene

func load_minigame(minigame: Minigames) -> PackedScene:
	match minigame:
		Minigames.Fishing:
			return load("res://scenes/minigames/fishing/fishing.tscn")
		_:
			push_error("No minigame scene provided for " + Minigames.keys()[minigame])
			return load("")

# Does this really need to be hardcoded?
func get_window_size(minigame: Minigames) -> Vector2:
	match minigame:
		Minigames.Fishing:
			return Vector2(30, 55)
		_:
			push_error("No minigame size provided for " + Minigames.keys()[minigame])
			return Vector2.ZERO

# TODO: Implement this
func calculate_position(initial_position: Vector2, window_size: Vector2) -> Vector2:
	return Vector2.ZERO
	for window: Control in get_children():
		# determine if the window has a possible position
		pass

func create_window(initial_position: Vector2, minigame: Minigames):
	var minigame_window = window_scene.instantiate() as MinigameWindow
	add_child(minigame_window)
	var window_size: Vector2 = get_window_size(minigame)
	var window_position: Vector2 = calculate_position(initial_position, window_size)
	minigame_window.place_window(window_position, window_size, load_minigame(minigame))