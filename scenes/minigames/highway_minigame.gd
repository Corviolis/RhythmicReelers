class_name HighwayMinigame
extends Minigame

@export var high_accuracy: int = 10
@export var low_accuracy: int = 20
@export var read_ahead_measures: int = 1

var notes: Array[NoteAnimation] = []
var highway: Array[BeatAnimation] = []
var note_scene: PackedScene
var beat_scene: PackedScene
var measure_scene: PackedScene
var read_ahead_seconds: float = read_ahead_measures * Conductor.measure_duration
var beatmap: MusicPlayer.BeatMap.Track
var start_time: float
var note_seek_head: float
var beat_seek_head: float
var beatcount: int = 0

@onready var game: Game = get_node("/root/Game") as Game
@onready var game_ui: Node2D = $Game
@onready var spawner: Marker2D = $Game/Spawner
@onready var target: Marker2D = $Game/Target
@onready var end: Marker2D = $Game/End


class BeatAnimation:
	var tween: Tween
	var beat_object: Node2D

	func _init(tween_in: Tween, beat_object_in: Node2D):
		self.tween = tween_in
		self.beat_object = beat_object_in


class NoteAnimation:
	extends BeatAnimation
	var note: MusicPlayer.BeatMap.Note

	func _init(tween_in: Tween, beat_object_in: Node2D, note_in: MusicPlayer.BeatMap.Note):
		self.tween = tween_in
		self.beat_object = beat_object_in
		self.note = note_in


func _ready():
	_specific_ready()
	var device = PlayerManager.get_player_device(player_id)
	input = DeviceInput.new(device)
	start_time = Conductor.get_time_of_next_measure() + Conductor.measure_duration
	note_seek_head = start_time
	beat_seek_head = start_time
	MusicPlayer.update_song_position.connect(_on_song_position)


func _specific_ready():
	pass


# ==== Helper Functions ====


# return closest note following note_seek_head
func _get_next_seek_note() -> MusicPlayer.BeatMap.Note:
	var index = beatmap.notes.find_custom(
		func(x: MusicPlayer.BeatMap.Note): return x.time >= note_seek_head
	)
	return beatmap.notes[index]


# Assumes TARGET_POS is necessarily a point on a straight line between START_POS and STOP_POS
func _calc_tween_time() -> float:
	var tween_speed := spawner.position.distance_to(target.position) / read_ahead_seconds
	var total_distance := spawner.position.distance_to(end.position)
	var total_time := total_distance / tween_speed
	return total_time


# Check how close the oldest alive beat is to the target
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
	var note_animation: BeatAnimation = notes.pop_front()
	note_animation.tween.kill()
	note_animation.beat_object.queue_free()
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


# ==== Callback Functions ====


# TODO: Rewrite to not use tween
# instead, directly use song_position as delta time to animate itself forward
func _on_song_position(song_position: float):
	if song_position > start_time - Conductor.measure_duration:
		$Label.visible = false
		$Game.visible = true
	else:
		$Label.text = str(snappedf(start_time - song_position - Conductor.measure_duration, 0.01))

	song_position += read_ahead_seconds
	if song_position < start_time:
		return

	# place beat & measure markers
	if song_position > beat_seek_head:
		var object: Node2D
		if beatcount == 0:
			object = measure_scene.instantiate() as Node2D
			if song_position > start_time + Conductor.measure_duration + 0.1:
				_add_resource()
		else:
			object = beat_scene.instantiate() as Node2D
		add_child(object)
		object.position = spawner.position

		var tween := create_tween()
		tween.tween_property(object, "position", end.position, _calc_tween_time()).set_trans(
			Tween.TRANS_LINEAR
		)
		tween.play()
		tween.tween_callback(
			func():
				tween.kill()
				object.queue_free()
		)
		highway.append(BeatAnimation.new(tween, object))

		beatcount += 1
		beatcount %= Conductor.beats_per_measure
		beat_seek_head += Conductor.beat_duration

	# place notes
	var next_note := _get_next_seek_note()
	if song_position > next_note.time:
		note_seek_head = next_note.time + 0.01

		var object = note_scene.instantiate()
		add_child(object)
		object.position = spawner.position

		var tween := create_tween()
		tween.tween_property(object, "position", end.position, _calc_tween_time()).set_trans(
			Tween.TRANS_LINEAR
		)
		tween.tween_callback(_missed_beat)
		tween.play()
		notes.append(NoteAnimation.new(tween, object, next_note))


func _add_resource():
	pass
