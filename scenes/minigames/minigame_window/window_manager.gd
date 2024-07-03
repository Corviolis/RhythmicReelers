class_name WindowManager
extends Node

enum Minigames {
	Fishing,
	Cutting,
	Packaging
}

var window_scene = load("res://scenes/minigames/minigame_window/minigame_window.tscn") as PackedScene
var pixel_mapping: Array[Array] # 2d grid of booleans, representing the available space for windows. true is occupied

@onready var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")

# === Pixel Grid Management

func _ready():
	# populate pixel grid
	for x in viewport_width:
		pixel_mapping.append([])
		for y in viewport_height:
			pixel_mapping[x].append(false)

# This function does *not* do any verification, handle that yourself nerd
func reserve_window(window_size: Vector2i, window_position: Vector2i):
	for x in range(window_position.x, window_position.x + window_size.x):
		for y in range(window_position.y, window_position.y + window_size.y):
			pixel_mapping[x][y] = true

func free_window(window_size: Vector2i, window_position: Vector2i):
	for x in range(window_position.x, window_position.x + window_size.x):
		for y in range(window_position.y, window_position.y + window_size.y):
			pixel_mapping[x][y] = false

# returns the first positional int closest to 0 (without crossing 0) that fits the size provided
# or return null if no size is found
func find_nearest_space(window_position: Vector2i, window_size: Vector2i): # -> int:
	# organize neighbours onto heap (or queue?) prioritised by distance (nearest first) (dx^2 + dy^2 or dx + dy)
	# pop each item off the ADT, if it's free use it, if not add it's neighbours to the ADT
	# https://stackoverflow.com/questions/17734591/algorithm-finding-closest-empty-square-a-2d-grid#comment25854085_17734711
	return 0

# TODO: Implement this
func calculate_position(initial_position: Vector2i, window_size: Vector2i) -> Vector2i:
	return initial_position

	# determine if there is enough vertical room to fit

# === Window Management

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
			return Vector2i(30, 55)
		Minigames.Cutting:
			return Vector2i(55, 30)
		_:
			push_error("No minigame size provided for " + Minigames.keys()[minigame])
			return Vector2.ZERO

func create_window(initial_position: Vector2i, minigame: Minigames):
	var minigame_window = window_scene.instantiate() as MinigameWindow
	add_child(minigame_window)
	var window_size: Vector2i = get_window_size(minigame)
	var window_position: Vector2i = calculate_position(initial_position, window_size)
	minigame_window.place_window(window_position, window_size, load_minigame(minigame))