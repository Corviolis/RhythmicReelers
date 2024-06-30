extends Node2D

@export
var beat_offset = 1000
@export
var accuracy = 0.5

var player_id = 1
var time = 0

func spawn_note(id: int, length: float, name: String):
	if player_id != id:
		return
	
	$Beat.position.x = 159
	$Beat.position.y = 192
	var tween = create_tween()
	tween.tween_property($Beat, "position", Vector2(159, 27), 1).set_trans(Tween.TRANS_LINEAR)
	tween.play()
	
func current_beat(id: int, length: float, name: String):
	if player_id != id:
		return
	
	time = 0
	
func _ready():
	RhythmEngine.future_beat.connect(spawn_note)
	RhythmEngine.current_beat.connect(current_beat)
	RhythmEngine.start_session(player_id, "fishing", 1, beat_offset)

func _exit_tree():
	RhythmEngine.end_session(player_id)

func _process(delta):
	time += delta
	
	if Input.is_action_just_pressed("beat"):
		if time <= accuracy:
			print("Hit!")
		else:
			print("BAD!")

func _physics_process(delta):
	pass
