class_name MinigameWindow
extends NinePatchRect

var progress_bar: ProgressBar


func setup_direction(window_size: Vector2i):
	progress_bar = find_child(&"ProgressBar")

	if window_size.x > window_size.y:  # horizontal
		region_rect = Rect2(2, 0, 3, 5)
		patch_margin_top = 3
		progress_bar.position = Vector2i(1, 1)
		progress_bar.size = Vector2i(window_size.x - 2, 1)
		progress_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
	else:  # vertical
		region_rect = Rect2(0, 0, 5, 3)
		patch_margin_left = 3
		progress_bar.position = Vector2i(1, 1)
		progress_bar.size = Vector2i(1, window_size.y - 2)
		progress_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	progress_bar.value = 15


func place_window(
	window_center: Vector2i,
	window_size: Vector2i,
	minigame_scene: PackedScene,
):
	size = Vector2i(window_size.x, window_size.y)
	position = Vector2i(window_center.x - window_size.x / 2, window_center.y - window_size.y / 2)
	var minigame = minigame_scene.instantiate() as Node2D
	minigame.apply_scale(Vector2(0.2, 0.2))

	add_child(minigame)
	setup_direction(window_size)
