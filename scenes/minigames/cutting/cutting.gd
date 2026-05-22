extends HighwayMinigame


func _specific_ready() -> void:
	beatmap = MusicPlayer.beat_map.tracks["Fishing"]
	note_scene = preload("res://scenes/minigames/cutting/note.tscn")
	beat_scene = preload("res://scenes/minigames/cutting/beat.tscn")
	measure_scene = preload("res://scenes/minigames/cutting/measure.tscn")


func _add_resource() -> void:
	game.add_cut_fish(1)
