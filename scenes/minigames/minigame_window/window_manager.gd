class_name WindowManager
extends Node

enum Minigames {
	Fishing,
	Cutting,
	Packaging
}

var window_scene = load("res://scenes/minigames/minigame_window/minigame_window.tscn") as PackedScene
var pixel_mapping: BitMap # 2d grid of booleans, representing the available space for windows. true is occupied

@onready var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")

# === Pixel Grid Management

func _ready():
	pixel_mapping = BitMap.new()
	pixel_mapping.create(Vector2i(viewport_width, viewport_height))

# This function does *not* do any verification, call calculate_position before you reserve space
# these functions might be consolidated later
func reserve_window(window_center: Vector2i, window_size: Vector2i):
	var window = Rect2i(window_center.x - window_size.x / 2, window_center.y - window_size.y / 2, window_size.x, window_size.y)
	pixel_mapping.set_bit_rect(window, true)

# maybe keep track of a list of active windows and remove those objects rather than directly addressing the bitmap?
func free_window(window_center: Vector2i, window_size: Vector2i):
	var window = Rect2i(window_center, window_size)
	pixel_mapping.set_bit_rect(window, false)

func array_to_screenspace(position: Vector2i) -> Vector2i:
	return Vector2i(position.x - viewport_width / 2, position.y - viewport_height / 2)

func screenspace_to_array(position: Vector2i) -> Vector2i:
	return Vector2i(position.x + viewport_width / 2, position.y + viewport_height / 2)

# check whether the passed position can fit the passed window size
func is_valid_position(center: Vector2i, window_size: Vector2i) -> bool:
	var vertical_radius: int = window_size.y / 2
	var horizontal_radius: int = window_size.x / 2

	# check that the window fits within the screen bounds
	if (center.x - horizontal_radius) < 0 or (center.x + horizontal_radius) > viewport_width:
		return false
	if (center.y - vertical_radius) < 0 or (center.y + vertical_radius) > viewport_width:
		return false

	for x in range(center.x - horizontal_radius, center.x + horizontal_radius):
		for y in range(center.y - vertical_radius, center.y + vertical_radius):
			if pixel_mapping.get_bit(x, y) == true:
				return false

	return true

func get_neighbours(index: Vector2i, cell_has_been_searched: BitMap) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	var x = index.x
	var y = index.y

	neighbours.append(Vector2i(x-1, y-1))
	neighbours.append(Vector2i(x-1, y))
	neighbours.append(Vector2i(x-1, y+1))

	neighbours.append(Vector2i(x, y-1))
	neighbours.append(Vector2i(x, y+1))

	neighbours.append(Vector2i(x+1, y-1))
	neighbours.append(Vector2i(x+1, y))
	neighbours.append(Vector2i(x+1, y+1))

	var ret: Array[Vector2i] = []
	for cell in neighbours:
		if cell.x < 0 or cell.x > viewport_width:
			pass
		elif cell.y < 0 or cell.y > viewport_height:
			pass
		elif not cell_has_been_searched.get_bitv(cell):
			cell_has_been_searched.set_bitv(cell, true)
			ret.append(cell)
	return ret

# returns the first position closest to window_position (without crossing 0) that fits the size provided
# or return null if no size is found
func find_nearest_space(initial_center: Vector2i, window_size: Vector2i) -> Vector2i:
	# transfer screen space (0,0 is center of screen) to array space (0,0 is top left corner)
	var center := screenspace_to_array(initial_center)
	var cell_has_been_searched := BitMap.new()
	cell_has_been_searched.create(Vector2i(viewport_width, viewport_height))

	# organize neighbours onto heap prioritised by distance (nearest first) (dx^2 + dy^2 or dx + dy)
	var search_min_heap: MinHeap = MinHeap.new()
	search_min_heap.initial_position = center
	search_min_heap.push(center)
	cell_has_been_searched.set_bitv(center, true)

	# pop each item off the heap, if it's free use it, if not add it's neighbours to the heap
	while true:
		var pixel: Vector2i = search_min_heap.pop()
		if is_valid_position(pixel, window_size):
			reserve_window(pixel, window_size)
			
			# transfer array space back to screen space
			var ret := array_to_screenspace(pixel)
			return ret
		search_min_heap.push_array(get_neighbours(pixel, cell_has_been_searched))

	return Vector2i.ZERO

# === Window Management

func load_minigame(minigame: Minigames) -> PackedScene:
	match minigame:
		Minigames.Fishing:
			return load("res://scenes/minigames/fishing/fishing.tscn")
		_:
			push_error("No minigame scene provided for " + Minigames.keys()[minigame])
			return load("")

# Does this really need to be hardcoded?
# Currently all windows need to be an odd size so they have a center
func get_window_size(minigame: Minigames) -> Vector2:
	match minigame:
		Minigames.Fishing:
			return Vector2i(31, 55)
		Minigames.Cutting:
			return Vector2i(55, 31)
		_:
			push_error("No minigame size provided for " + Minigames.keys()[minigame])
			return Vector2.ZERO

func create_window(initial_center: Vector2i, minigame: Minigames):

	var minigame_window = window_scene.instantiate() as MinigameWindow
	add_child(minigame_window)
	var window_size: Vector2i = get_window_size(minigame)
	var window_position: Vector2i = find_nearest_space(initial_center, window_size)
	minigame_window.place_window(window_position, window_size, load_minigame(minigame))