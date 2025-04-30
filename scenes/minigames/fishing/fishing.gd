extends Minigame

@export var minigame_duration_in_measures = 1
@export var beat_offset = 2
@export var high_accuracy = 50
@export var low_accuracy = 100

var beats: Array[BeatAnimation] = []
var time_to_target: float
var beat_scene: PackedScene = preload("res://scenes/minigames/fishing/beat.tscn")
var playing: bool = false
var counting_measures: bool = false
var measures_alive: int = 0

@onready var spawner: Marker2D = $Spawner
@onready var target: Marker2D = $Target
@onready var end: Marker2D = $End

# TODO: close minigames when the song ends


class BeatAnimation:
	var tween: Tween
	var beat_object: Node2D
	var beat_index: int

	func _init(tween_in: Tween, beat_object_in: Node2D, beat_index_in: int):
		self.tween = tween_in
		self.beat_object = beat_object_in
		self.beat_index = beat_index_in


func _enter_tree():
	set_multiplayer_authority(PlayerManager.get_player_authority(player_id))


func _ready():
	RhythmEngine.system_measure.connect(on_system_measure)
	RhythmEngine.session_beat.connect(on_beat)
	RhythmEngine.start_session(player_id, WindowManager.Minigames.FISHING, 1, beat_offset)

	var device = PlayerManager.get_player_device(player_id)
	input = DeviceInput.new(device)


func _process(_delta: float):
	_handle_input()


func _handle_input():
	if !is_multiplayer_authority():
		return
	if input.is_action_just_pressed("beat"):
		_beat()


func _exit_tree():
	PlayerManager.stop_player_minigame(player_id)
	RhythmEngine.end_session(player_id)
	for beat in beats:
		beat.tween.kill()
		beat.beat_object.queue_free()


# ==== Helper Functions ====


# Assumes TARGET_POS is necessarily a point on a straight line between START_POS and STOP_POS
func _calc_tween_time() -> float:
	var tween_speed := spawner.position.distance_to(target.position) / time_to_target
	var total_distance := spawner.position.distance_to(end.position)
	var total_time := total_distance / tween_speed
	return total_time


# Check how close the oldest alive beat is to the target
func _beat():
	if len(beats) == 0:
		return
	var beat_animation: BeatAnimation = beats.front()
	var hit_time: float = RhythmEngine.hit(
		player_id, "Electric Piano", beat_animation.beat_index, beat_offset
	)
	_handle_beat_result.rpc(hit_time)
	return snappedf(hit_time, 0.01)


@rpc("any_peer", "call_local", "reliable")
func _handle_beat_result(hit_time: float):
	var beat_animation: BeatAnimation = beats.pop_front()
	beat_animation.tween.kill()
	beat_animation.beat_object.queue_free()
	match true:
		_ when abs(hit_time) <= high_accuracy:
			print("Nice! %s" % hit_time)
		_ when hit_time < 0 and abs(hit_time) <= high_accuracy + 100:
			print("Slightly Slow! %s" % hit_time)
		_ when hit_time > 0 and abs(hit_time) <= high_accuracy + 100:
			print("Slightly Fast! %s" % hit_time)
		_ when hit_time < 0 and abs(hit_time) > high_accuracy + 100:
			print("Very Slow! %s" % hit_time)
		_ when hit_time > 0 and abs(hit_time) > high_accuracy + 100:
			print("Very Fast! %s" % hit_time)
		_:
			printerr("Impossible hit time! %s" % hit_time)


# ==== Callback Functions ====


# TODO: ignore beats that would arrive after the minigame ends
# Updates beats array and creats Beat game object when a beat is received
func on_beat(minigame_player_id: int, _length: float, _track: String, index: int):
	if minigame_player_id != player_id:
		return
	if RhythmEngine.get_beats_left_in_measure() == 1:
		playing = true
	if not playing:
		return

	var song_changes = RhythmEngine.get_current_song_changes(RhythmEngine.song_position_in_ms)
	time_to_target = (beat_offset * RhythmEngine.calculate_seconds_per_beat(song_changes.bpm))

	var beat_object = beat_scene.instantiate()
	add_child(beat_object)
	beat_object.position = spawner.position

	var tween := create_tween()
	tween.tween_property(beat_object, "position", end.position, _calc_tween_time()).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_callback(_beat)
	tween.play()
	beats.append(BeatAnimation.new(tween, beat_object, index))


# TODO: wait a beat before killing the minigame
func on_system_measure():
	if counting_measures:
		measures_alive += 1
	if measures_alive >= minigame_duration_in_measures:
		get_parent().queue_free()
	counting_measures = true
