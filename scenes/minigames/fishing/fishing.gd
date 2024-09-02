extends Node2D

@export
var beat_offset = 1000
@export
var accuracy = 50  
	   
var player_id = 1

func on_beat(id: int, length: float, track: String):
	if player_id != id:
		return
	
	$Beat.position.x = 159
	$Beat.position.y = 192
	var tween = create_tween()
	tween.tween_property($Beat, "position", Vector2(159, 27), beat_offset / 1000  ).set_trans(Tween.TRANS_LINEAR)
	tween.play()
	
func _ready():
	RhythmEngine.beat_sig.connect(on_beat)
	RhythmEngine.start_session(player_id, "fishing", 1, beat_offset)

func _exit_tree():
	RhythmEngine.end_session(player_id)

func _process(delta):
	if Input.is_action_just_pressed("beat"):
		if RhythmEngine.hit(player_id, "Electric Piano", accuracy):
			print("Hit!")
		else:
			print("BAD!")

func _physics_process(delta):
	pass
