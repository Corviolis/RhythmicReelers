class_name WindowManager
extends Node

enum Minigames { Fishing, Cutting, Packaging }

var window_scene = (
	load("res://scenes/minigames/minigame_window/minigame_window.tscn") as PackedScene
)
var pixel_mapping: BitMap  # 2d grid of booleans, representing the available space for windows. true is occupied
const WINDOW_PADDING: int = 1

@onready
var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")

# === Window Manager


class BitmapWindow:
	var center: Vector2i
	var size: Vector2i

	func _init(window_center: Vector2i, window_size: Vector2i) -> void:
		self.center = window_center
		self.size = window_size

	func get_neighbours() -> Array[Vector2i]:
		var vertical_radius: int = size.y / 2 + WINDOW_PADDING
		var horizontal_radius: int = size.x / 2 + WINDOW_PADDING
		var ret: Array[Vector2i] = []
		for x in range(
			center.x - (horizontal_radius + WINDOW_PADDING + 1),
			center.x + (horizontal_radius + WINDOW_PADDING + 1)
		):
			ret.push_back(Vector2i(x, center.y - (horizontal_radius + WINDOW_PADDING + 1)))
			ret.push_back(Vector2i(x, center.y + (horizontal_radius + WINDOW_PADDING + 1)))
		for y in range(
			center.y - (vertical_radius + WINDOW_PADDING + 1),
			center.y + (vertical_radius + WINDOW_PADDING + 1)
		):
			ret.push_back(Vector2i(center.x - (vertical_radius + WINDOW_PADDING + 1), y))
			ret.push_back(Vector2i(center.x + (vertical_radius + WINDOW_PADDING + 1), y))
		return ret

	func get_pixels() -> Array[Vector2i]:
		var vertical_radius: int = size.y / 2 + WINDOW_PADDING
		var horizontal_radius: int = size.x / 2 + WINDOW_PADDING
		var ret: Array[Vector2i] = []
		for x in range(
			center.x - (horizontal_radius + WINDOW_PADDING),
			center.x + (horizontal_radius + WINDOW_PADDING)
		):
			for y in range(
				center.y - (vertical_radius + WINDOW_PADDING),
				center.y + (vertical_radius + WINDOW_PADDING)
			):
				ret.push_back(Vector2i(x, y))
		return ret


var bitmap_windows: Array[BitmapWindow] = []

# === Pixel Grid Management


func _ready():
	pixel_mapping = BitMap.new()
	pixel_mapping.create(Vector2i(viewport_width, viewport_height))


func reserve_window(window_center: Vector2i, window_size: Vector2i):
	bitmap_windows.push_back(BitmapWindow.new(window_center, window_size))
	var window = Rect2i(
		window_center.x - window_size.x / 2,
		window_center.y - window_size.y / 2,
		window_size.x,
		window_size.y
	)
	pixel_mapping.set_bit_rect(window, true)


func free_window(bitmap_window: BitmapWindow):
	assert(!bitmap_windows.has(bitmap_window))  # pop the bitmap window from bitmap_windows
	var window = Rect2i(bitmap_window.window_center, bitmap_window.window_size)
	pixel_mapping.set_bt_rect(window, false)


func array_to_screenspace(position: Vector2i) -> Vector2i:
	return Vector2i(position.x - viewport_width / 2, position.y - viewport_height / 2)


func screenspace_to_array(position: Vector2i) -> Vector2i:
	return Vector2i(position.x + viewport_width / 2, position.y + viewport_height / 2)


# check whether the passed position can fit the passed window size
func is_valid_position(center: Vector2i, window_size: Vector2i) -> bool:
	# because of this windows need to be an odd width & height
	# this is a trade-off, and it lets us position windows from their center
	var vertical_radius: int = window_size.y / 2 + WINDOW_PADDING
	var horizontal_radius: int = window_size.x / 2 + WINDOW_PADDING

	# check that the window fits within the screen bound
	if (center.x - horizontal_radius) < 0 or (center.x + horizontal_radius) >= viewport_width:
		return false
	if (center.y - vertical_radius) < 0 or (center.y + vertical_radius) >= viewport_height:
		return false

	# check very center because padding can cause misses
	if pixel_mapping.get_bit(center.x, center.y) == true:
		return false

	# check if borders of window are un-occupied
	# don't check inside window for efficiency

	for x in range(center.x - horizontal_radius, center.x + horizontal_radius):
		if pixel_mapping.get_bit(x, center.y - vertical_radius) == true:
			return false
		if pixel_mapping.get_bit(x, center.y + vertical_radius) == true:
			return false

	for y in range(center.y - vertical_radius, center.y + vertical_radius):
		if pixel_mapping.get_bit(center.x - horizontal_radius, y) == true:
			return false
		if pixel_mapping.get_bit(center.x + horizontal_radius, y) == true:
			return false

	return true


func get_neighbours(index: Vector2i, searched_bitmap: BitMap) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	var x = index.x
	var y = index.y

	neighbours.append(Vector2i(x - 1, y - 1))
	neighbours.append(Vector2i(x - 1, y))
	neighbours.append(Vector2i(x - 1, y + 1))

	neighbours.append(Vector2i(x, y - 1))
	neighbours.append(Vector2i(x, y + 1))

	neighbours.append(Vector2i(x + 1, y - 1))
	neighbours.append(Vector2i(x + 1, y))
	neighbours.append(Vector2i(x + 1, y + 1))

	var ret: Array[Vector2i] = []
	for cell in neighbours:
		if cell.x < 0 or cell.x >= viewport_width:
			pass
		elif cell.y < 0 or cell.y >= viewport_height:
			pass
		elif not searched_bitmap.get_bitv(cell):
			searched_bitmap.set_bitv(cell, true)
			ret.append(cell)
	return ret


# returns the first position closest to window_position (without crossing 0) that fits the size provided
# or return (0, 0) if no size is found
# TODO expand past existing window border by the length of the radius (assume the window won't fit directly next to another window)
func find_nearest_space(initial_center: Vector2i, window_size: Vector2i) -> Vector2i:
	# transfer screen space (0,0 is center of screen) to array space (0,0 is top left corner)
	var center := screenspace_to_array(initial_center)
	var searched_bitmap := BitMap.new()
	searched_bitmap.create(Vector2i(viewport_width, viewport_height))

	var search_queue_min_heap := MinHeap.new()
	search_queue_min_heap.initial_position = center
	search_queue_min_heap.push(center)
	searched_bitmap.set_bitv(center, true)

	# pop each pixel off the heap, if it's free use it, if not add it's neighbours to the heap
	while true:
		var pixel: Vector2i = search_queue_min_heap.pop()
		if is_valid_position(pixel, window_size):
			return pixel
		# organize neighbours onto heap prioritised by distance (nearest first) (dx^2 + dy^2 or dx + dy)
		search_queue_min_heap.push_array(get_neighbours(pixel, searched_bitmap))

	return Vector2i.ZERO


# === Window Management


func load_minigame(minigame: Minigames) -> PackedScene:
	match minigame:
		Minigames.Fishing:
			return load("res://scenes/minigames/fishing/fishing.tscn")
		Minigames.Cutting:
			push_error("Using a test scene for Cutting")
			return load("res://scenes/minigames/cutting/cutting_test.tscn")
		_:
			push_error("No minigame scene provided for " + Minigames.keys()[minigame])
			return load("")


# Should this be stored here? (or stored at all?)
# Currently all windows need to be an odd size so they have a center pixel
func get_window_size(minigame: Minigames) -> Vector2:
	match minigame:
		Minigames.Fishing:
			return Vector2i(31, 55)
		Minigames.Cutting:
			return Vector2i(55, 31)
		_:
			push_error("No minigame size provided for " + Minigames.keys()[minigame])
			return Vector2.ZERO


func create_window(initial_center: Vector2i, minigame: Minigames, minigame_material: Material):
	var minigame_window = window_scene.instantiate() as MinigameWindow
	minigame_window.material = minigame_material
	add_child(minigame_window)

	var window_size: Vector2i = get_window_size(minigame)
	assert(window_size != Vector2i.ZERO)

	var window_position: Vector2i = find_nearest_space(initial_center, window_size)
	assert(window_position != Vector2i.ZERO)
	reserve_window(window_position, window_size)
	window_position = array_to_screenspace(window_position)

	minigame_window.place_window(window_position, window_size, load_minigame(minigame))
