class_name WindowManager
extends Node

enum Minigames {
	Fishing,
	Cutting,
	Packaging
}

var window_scene = load("res://scenes/minigames/minigame_window/minigame_window.tscn") as PackedScene
var pixel_mapping: Array[Array] # 2d grid of booleans, representing the available space for windows. true is occupied
var breadth_first_array: Array[Array] # 2d grid of ints, representing whether or not the relevant pixel has been searched yet
var search_increment: int = 0 # the current search, this is compared to the breadth_first_array to invalidate previous searches
var search_min_heap: MinHeap = MinHeap.new()

# having a persistant search array (search_min_heap validated by breadth_first_array validated by search_increment) is useful for two reasons:
# 1. it removes the need to recreate/reset the array each time a search needs to be made, making the operation more efficient
# 2. it allows us to 'resume' a search after failing validation, saving the need to redo work

@onready var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")

# === Pixel Grid Management

# this might not be necessary
# TODO: Delete later if this proves irrelevant
func _ready():
	pixel_mapping.resize(viewport_width)
	for i in pixel_mapping.size():
		pixel_mapping[i].resize(viewport_height)
		pixel_mapping[i].fill(false)
	breadth_first_array.resize(viewport_width)
	for i in breadth_first_array.size():
		breadth_first_array[i].resize(viewport_height)
		breadth_first_array[i].fill(0)

# This function does *not* do any verification, call calculate_position before you reserve space
# these functions might be consolidated later
func reserve_window(window_size: Vector2i, window_position: Vector2i):
	for x in range(window_position.x, window_position.x + window_size.x):
		for y in range(window_position.y, window_position.y + window_size.y):
			pixel_mapping[x][y] = true

func free_window(window_size: Vector2i, window_position: Vector2i):
	for x in range(window_position.x, window_position.x + window_size.x):
		for y in range(window_position.y, window_position.y + window_size.y):
			pixel_mapping[x][y] = false

# returns the first position closest to window_position (without crossing 0) that fits the size provided
# or return null if no size is found
func find_nearest_space(initial_position: Vector2i, window_size: Vector2i) -> Vector2i:
	# organize neighbours onto heap prioritised by distance (nearest first) (dx^2 + dy^2 or dx + dy)

	# pop each item off the ADT, if it's free use it, if not add it's neighbours to the ADT
	# https://stackoverflow.com/questions/17734591/algorithm-finding-closest-empty-square-a-2d-grid#comment25854085_17734711
	return Vector2i.ZERO

# TODO: Implement this
func calculate_position(initial_position: Vector2i, window_size: Vector2i) -> Vector2i:
	return initial_position
	find_nearest_space(initial_position, window_size)
	# determine if it's a valid place
	# invalidate those pixels if it's not (hahahahahahaha this definitely sounds fun...)
	## does this mean I need to recursivly invalidate pixels until I find an occupied pixel wall or a valid location?
	# repeat find nearest space
	## this means we can't dispose of the heap until we've confirmed a valid location
	## add pixels adjacent to the 'border' of the invalidated area to the heap
	### or wait, maybe we should still search them to not mess with the spacing, but we don't actually consider them as free?

	# OR

	# algorithmically determine all possible largest cubes
	# place the window in the nearest available spot

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