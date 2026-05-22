extends HighwayMinigame


func _specific_ready() -> void:
	beatmap = MusicPlayer.beat_map.tracks["Fishing"]
	note_scene = preload("res://scenes/minigames/fishing/note.tscn")
	beat_scene = preload("res://scenes/minigames/fishing/beat.tscn")
	measure_scene = preload("res://scenes/minigames/fishing/measure.tscn")


func _add_resource() -> void:
	game.add_raw_fish(1)
