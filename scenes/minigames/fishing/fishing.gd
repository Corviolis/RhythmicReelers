extends Minigame

@export var beat_offset = 1000
@export var accuracy = 50


func on_beat(player: Player, _length: float, _track: String):
	if minigame_player != player:
		return

	$Beat.position.x = 159
	$Beat.position.y = 192
	var tween = create_tween()
	tween.tween_property($Beat, "position", Vector2(159, 27), beat_offset / 1000).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.play()


func _ready():
	RhythmEngine.player_beat.connect(on_beat)
	RhythmEngine.start_session(
		minigame_player.player_id, WindowManager.Minigames.Fishing, 1, beat_offset
	)


func _exit_tree():
	minigame_player.in_minigame = false
	RhythmEngine.end_session(minigame_player.player_id)


func _process(_delta):
	if Input.is_action_just_pressed("beat"):
		var hit_time = RhythmEngine.hit(minigame_player.player_id, "Electric Piano")
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
