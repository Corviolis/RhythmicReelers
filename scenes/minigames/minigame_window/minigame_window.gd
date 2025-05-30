class_name MinigameWindow
extends NinePatchRect

var progress_bar: ProgressBar
var progress_bar_delta: float = 0
var progress_bar_target: float = 0
var window: WindowManager.BitmapWindow
var interactable: StationInteractable


func _exit_tree() -> void:
	WindowManager.free_window(window)
	interactable.playing = false


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
	window_center: Vector2i, window_size: Vector2i, minigame_scene: PackedScene, player_id: int
):
	size = Vector2i(window_size.x, window_size.y)
	position = Vector2i(window_center.x - window_size.x / 2, window_center.y - window_size.y / 2)
	var minigame: Minigame = minigame_scene.instantiate() as Minigame
	minigame.apply_scale(Vector2(0.2, 0.2))
	minigame.player_id = player_id

	add_child(minigame)
	setup_direction(window_size)


func fill_progess_bar_over_time(value: float, duration: float) -> void:
	progress_bar_delta = (progress_bar.value - value) / duration
	progress_bar_target = value


func _process(delta: float) -> void:
	if progress_bar.value < progress_bar_target:
		progress_bar.value += delta * progress_bar_delta
