extends Minigame

const START_POS = Vector2(159, 192)
const TARGET_POS = Vector2(159, 27)
const STOP_POS = Vector2(159, 0)

@export var beat_offset = 1000
@export var accuracy = 50

var beats: Array[Tween] = []
var time_to_target: float = beat_offset / 1000


func _enter_tree() -> void:
	set_multiplayer_authority(PlayerManager.get_player_authority(player_id))


func _ready():
	RhythmEngine.player_beat.connect(on_beat)
	RhythmEngine.start_session(player_id, WindowManager.Minigames.Fishing, 1, beat_offset)

	var device = PlayerManager.get_player_device(player_id)
	input = DeviceInput.new(device)


func _process(_delta: float):
	_handle_input()


func _handle_input():
	if !is_multiplayer_authority():
		return
	if input.is_action_pressed("beat"):
		_beat()


func _exit_tree():
	#minigame_player.in_minigame = false
	RhythmEngine.end_session(player_id)


# ==== Helper Functions ====


# Assumes TARGET_POS is necessarily a point on a straight line between START_POS and STOP_POS
func _calc_tween_time():
	var tween_speed := START_POS.distance_to(TARGET_POS) / time_to_target
	var total_distance := START_POS.distance_to(STOP_POS)
	var total_time := total_distance / tween_speed
	return total_time


# Check how close the oldest alive beat is to the target
func _beat():
	if len(beats) == 0:
		return
	beats.pop_front().kill()
	$Beat.hide()
	var hit_time: float = RhythmEngine.hit(player_id, "Electric Piano")
	hit_time = snappedf(hit_time, 0.01)
	match true:
		_ when abs(hit_time) <= accuracy:
			print("Nice! %s" % hit_time)
		_ when hit_time < 0 and abs(hit_time) <= accuracy + 100:
			print("Slightly Slow! %s" % hit_time)
		_ when hit_time > 0 and abs(hit_time) <= accuracy + 100:
			print("Slightly Fast! %s" % hit_time)
		_ when hit_time < 0 and abs(hit_time) > accuracy + 100:
			print("Very Slow! %s" % hit_time)
		_ when hit_time > 0 and abs(hit_time) > accuracy + 100:
			print("Very Fast! %s" % hit_time)
		_:
			printerr("Impossible hit time! %s" % hit_time)
	return hit_time


# ==== Callback Functions ====


# Updates BEAT game object when a beat is received
# TODO: Assumes there will never be more than one active beat at a time -- fix this
func on_beat(minigame_player_id: int, _length: float, _track: String):
	if minigame_player_id != player_id:
		return

	$Beat.position = START_POS
	$Beat.show()
	var tween := create_tween()
	tween.tween_property($Beat, "position", STOP_POS, _calc_tween_time()).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_callback(_beat)
	tween.play()
	beats.append(tween)
