class_name MinigameWindow
extends NinePatchRect

var progress_bar: ProgressBar

func setup_direction(width: int, height: int):
	progress_bar = find_child(&"ProgressBar")

	if width > height: # horizontal
		print("horizontal")
		region_rect = Rect2(2, 0, 3, 5)
		patch_margin_top = 3
		progress_bar.position = Vector2(1, 1)
		progress_bar.size = Vector2(width - 2, 1)
		progress_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
	else: # vertical
		print("vertical")
		region_rect = Rect2(0, 0, 5, 3)
		patch_margin_left = 3
		progress_bar.position = Vector2(1, 1)
		progress_bar.size = Vector2(1, height - 2)
		progress_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	progress_bar.value = 15

func place_window(window_position: Vector2, width: int, height: int, _minigame_scene: PackedScene):
	size = Vector2(width, height)
	position = Vector2(window_position.x - width / 2.0, window_position.y - height / 2.0)
	# var minigame = minigame_scene.instantiate() as Node2D
	# add_child(minigame)
	setup_direction(width, height)