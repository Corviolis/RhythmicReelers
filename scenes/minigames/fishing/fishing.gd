extends Minigame

@export var beat_offset = 2
@export var high_accuracy = 50
@export var low_accuracy = 100

var beats: Array[BeatAnimation] = []
var time_to_target: float
var beat_scene: PackedScene = preload("res://scenes/minigames/fishing/beat.tscn")

@onready var spawner: Marker2D = $Spawner
@onready var target: Marker2D = $Target
@onready var end: Marker2D = $End


class BeatAnimation:
	var tween: Tween
	var beat_object: Node2D

	func _init(tween: Tween, beat_object: Node2D):
		self.tween = tween
		self.beat_object = beat_object


func _enter_tree() -> void:
	set_multiplayer_authority(PlayerManager.get_player_authority(player_id))


# TODO: Hold for next start of measure
func _ready():
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
		print("beat")
		_beat()


func _exit_tree():
	#minigame_player.in_minigame = false
	RhythmEngine.end_session(player_id)


# ==== Helper Functions ====


# Assumes TARGET_POS is necessarily a point on a straight line between START_POS and STOP_POS
func _calc_tween_time():
	var tween_speed := spawner.position.distance_to(target.position) / time_to_target
	var total_distance := spawner.position.distance_to(end.position)
	var total_time := total_distance / tween_speed
	return total_time


# Check how close the oldest alive beat is to the target
func _beat():
	if len(beats) == 0:
		return
	print("hit")
	var beat_animation: BeatAnimation = beats.pop_front()
	beat_animation.tween.kill()
	beat_animation.beat_object.queue_free()
	var hit_time: float = RhythmEngine.hit(player_id, "Electric Piano")
	_handle_beat_result.rpc(hit_time)
	return snappedf(hit_time, 0.01)


@rpc("any_peer", "call_local", "reliable")
func _handle_beat_result(hit_time: float):
	print(player_id)
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


# Updates BEAT game object when a beat is received
func on_beat(minigame_player_id: int, _length: float, _track: String):
	if minigame_player_id != player_id:
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
	beats.append(BeatAnimation.new(tween, beat_object))
