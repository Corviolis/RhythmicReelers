extends Minigame

@export var high_accuracy: int = 10
@export var low_accuracy: int = 20
@export var read_ahead_beats: int = 1

var using_mouse: bool = false
var crosshair_speed: float = 200
var notes: Array[NoteAnimation] = []
var note_scene: PackedScene = preload("res://scenes/minigames/shooting/note.tscn")
var beatmap: MusicPlayer.BeatMap.Track
var read_ahead_seconds: float = read_ahead_beats * Conductor.beat_duration
var start_time: float
var note_seek_head: float
var beat_seek_head: float
var beatcount: int = 0


class NoteAnimation:
	var beat_object: Sprite2D
	var note: MusicPlayer.BeatMap.Note
	var frame_time: float
	var start_time: float
	var time_to_hit_from_start_time: float
	var missed_beat: Callable
	var queued_to_delete: bool = false

	func _init(
		beat_object_in: Sprite2D,
		note_in: MusicPlayer.BeatMap.Note,
		time_until_hit: float,
		missed_beat_in: Callable
	):
		self.beat_object = beat_object_in
		self.note = note_in
		self.frame_time = time_until_hit / beat_object_in.hframes
		self.start_time = MusicPlayer.song_position
		self.missed_beat = missed_beat_in
		MusicPlayer.update_song_position.connect(_on_song_position)

	func _on_song_position(song_position: float):
		var frame: int = max(floori((song_position - start_time) / frame_time), 0)
		if frame >= beat_object.hframes and not queued_to_delete:
			var timer = Timer.new()
			timer.one_shot = true
			timer.autostart = true
			timer.wait_time = 0.2
			timer.timeout.connect(func(): missed_beat.call())
			beat_object.add_child(timer)
			queued_to_delete = true
			return
		beat_object.frame = mini(frame, beat_object.hframes - 1)

	func kill():
		MusicPlayer.update_song_position.disconnect(_on_song_position)
		beat_object.queue_free()


func _ready():
	var device = PlayerManager.get_player_device(player_id)
	input = DeviceInput.new(device)
	beatmap = MusicPlayer.beat_map.tracks["Fishing"]
	MusicPlayer.update_song_position.connect(_on_song_position)
	Conductor.beat.connect(_on_beat)


func _process(delta: float):
	_handle_input(delta)


func _beat():
	if len(notes) == 0:
		return
	var target_note := notes[0]
	var hit_time: float = (MusicPlayer.song_position - target_note.note.time) * 100
	_handle_beat_result.rpc(hit_time)


func _missed_beat():
	if len(notes) == 0:
		return
	var target_note := notes[0]
	var hit_time: float = (MusicPlayer.song_position - target_note.note.time) * 100
	_handle_beat_result.rpc(hit_time, true)


@rpc("any_peer", "call_local", "reliable")
func _handle_beat_result(hit_time: float, missed: bool = false):
	var note_animation: NoteAnimation = notes.pop_front()
	note_animation.kill()
	if missed:
		print("Missed! %s" % hit_time)
		return
	match true:
		_ when abs(hit_time) <= high_accuracy:
			print("Nice! %s" % hit_time)
		_ when hit_time > 0 and abs(hit_time) <= low_accuracy:
			print("Slightly Slow! %s" % hit_time)
		_ when hit_time < 0 and abs(hit_time) <= low_accuracy:
			print("Slightly Fast! %s" % hit_time)
		_ when hit_time > 0 and abs(hit_time) > low_accuracy:
			print("Very Slow! %s" % hit_time)
		_ when hit_time < 0 and abs(hit_time) > low_accuracy:
			print("Very Fast! %s" % hit_time)
		_:
			printerr("Impossible hit time! %s" % hit_time)


func _on_song_position(_song_position: float):
	pass


func _on_beat(_beat_count: int):
	_create_note(MusicPlayer.BeatMap.Note.new(MusicPlayer.song_position + read_ahead_seconds))


func _create_note(note: MusicPlayer.BeatMap.Note):
	var note_object = note_scene.instantiate() as Sprite2D
	add_child(note_object)
	notes.append(NoteAnimation.new(note_object, note, read_ahead_seconds, _missed_beat))


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
