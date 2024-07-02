class_name MinigameWindow
extends NinePatchRect

enum Minigames {
	Fishing,
	Cutting,
	Packaging
}

func load_minigame(minigame: Minigames) -> PackedScene:
	match minigame:
		Minigames.Fishing:
			print("fishing hit")
			return load("res://scenes/minigames/fishing/fishing.tscn")
		_:
			push_error("No minigame scene provided for " + Minigames.keys()[minigame])
			return load("")

func place_window(initial_position: Vector2, width: int, height: int, minigame: Minigames):
	size = Vector2(width, height)
	position = initial_position
	if width > height:
		region_rect = Rect2(2, 0, 3, 5)
		patch_margin_top = 3
	else:
		region_rect = Rect2(0, 0, 5, 3)
		patch_margin_left = 3
	var minigame_scene = load_minigame(minigame).instantiate() as Node2D
	add_child(minigame_scene)
