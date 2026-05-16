extends Minigame

@export var high_accuracy: int = 10
@export var low_accuracy: int = 20
@export var read_ahead_measures: int = 1

var using_mouse: bool = false
var crosshair_speed: float = 200
var notes: Array[NoteAnimation] = []
var note_scene: PackedScene
var beatmap: MusicPlayer.BeatMap.Track
var read_ahead_seconds: float = read_ahead_measures * Conductor.measure_duration
var start_time: float
var note_seek_head: float
var beat_seek_head: float
var beatcount: int = 0


class NoteAnimation:
	var tween: Tween
	var beat_object: Node2D
	var note: MusicPlayer.BeatMap.Note

	func _init(tween_in: Tween, beat_object_in: Node2D, note_in: MusicPlayer.BeatMap.Note):
		self.tween = tween_in
		self.beat_object = beat_object_in
		self.note = note_in


func _ready():
	var device = PlayerManager.get_player_device(player_id)
	input = DeviceInput.new(device)
	beatmap = MusicPlayer.beat_map.tracks["Fishing"]
	note_scene = preload("res://scenes/minigames/fishing/note.tscn")


func _process(delta: float):
	_handle_input(delta)


func _beat():
	pass


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		using_mouse = true


func _handle_input(delta: float):
	if !is_multiplayer_authority():
		return
	if input.is_action_just_pressed("exit"):
		_exit_minigame()
	if input.is_action_just_pressed("beat"):
		_beat()

	var movement_vector := input.get_vector("move_left", "move_right", "move_up", "move_down")
	if movement_vector != Vector2.ZERO:
		using_mouse = false
	if using_mouse and input.is_keyboard():
		position = get_global_mouse_position()
	position += movement_vector * delta * crosshair_speed
	position.x = maxf(position.x, -get_viewport().get_visible_rect().size.x / (2 * 4))
	position.y = maxf(position.y, -get_viewport().get_visible_rect().size.y / (2 * 4))
	position.x = minf(position.x, get_viewport().get_visible_rect().size.x / (2 * 4))
	position.y = minf(position.y, get_viewport().get_visible_rect().size.y / (2 * 4))
