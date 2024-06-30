extends Node2D

@export
var beat_offset = 200
var player_id = 1

func spawn_note(id: int, length: float, name: String):
	#if player_id != id:
		#return
	
	print("beat!")
	
func _ready():
	RhythmEngine.future_beat.connect(spawn_note)
	RhythmEngine.start_session(player_id, "fishing", 1, beat_offset)

func _exit_tree():
	RhythmEngine.end_session(player_id)

func _process(delta):
	pass
