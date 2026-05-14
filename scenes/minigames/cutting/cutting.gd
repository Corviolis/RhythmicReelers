extends Highway_Minigame


func _specific_ready():
	beatmap = MusicPlayer.beat_map.tracks["Fishing"]
	note_scene = preload("res://scenes/minigames/cutting/note.tscn")
	beat_scene = preload("res://scenes/minigames/cutting/beat.tscn")
	measure_scene = preload("res://scenes/minigames/cutting/measure.tscn")


func _add_resource():
	game.add_cut_fish(1)
