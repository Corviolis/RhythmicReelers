extends Node

signal beat_sig(player_id: int, length: float, track: String)

# see _get_filesystem_beatmaps() documentation
var beatmaps: Dictionary

var song: String
var audio = AudioStreamPlayer.new()
var song_position: float
var sessions: Array[Session] = []


class Session:
	var tracks: Array
	var future_beat_offset: int
	var future_beat_sent: Dictionary

	func _init(minigame: WindowManager.Minigames, difficulty: int, offset: int):
		future_beat_offset = offset

		var minigame_name: String = WindowManager.Minigames.keys()[minigame]
		var beatmap_name: String = minigame_name.to_lower() + "-" + str(difficulty)
		var beatmap: BeatMap = RhythmEngine.beatmaps[RhythmEngine.song][beatmap_name]
		tracks = beatmap.get_tracks()
		for track in tracks:
			future_beat_sent[track.name] = false


func _ready():
	sessions.resize(4)
	beatmaps = _get_filesystem_beatmaps()
	add_child(audio)
	play_song("test_song")


func _process(_delta):
	song_position = (
		(
			audio.get_playback_position()
			+ AudioServer.get_time_since_last_mix()
			- AudioServer.get_output_latency()
		)
		* 1000
	)

	for id in range(sessions.size()):
		var session = sessions[id]
		if session == null:
			continue

		for track in session.tracks:
			# Scan for position in beatmap
			var beat = track.get_beat()
			#while song_position > beat.pos:
			#beat = track.next()

			if song_position >= beat.pos:
				session.future_beat_sent[track.name] = false
				track.next()
				continue

			if (
				!session.future_beat_sent[track.name]
				&& song_position >= beat.pos - session.future_beat_offset
			):
				beat_sig.emit(id, beat.len, track.name)
				session.future_beat_sent[track.name] = true


#===== Session Management =====


func start_session(player_id: int, minigame: WindowManager.Minigames, difficulty: int, offset: int):
	sessions[player_id] = Session.new(minigame, difficulty, offset)


func end_session(player_id: int):
	sessions[player_id] = null


#===== Gameplay / State Management =====


func hit(player_id: int, track_name: String, accuracy: float):
	for track in sessions[player_id].tracks:
		if track.name == track_name:
			return track.get_time_to_closest(song_position) - accuracy <= 0


func play_song(song_name: String):
	song = song_name
	audio.stream = load("res://music/" + song_name + "/" + song_name + ".mp3")
	audio.play()


#===== File Reading =====


# returns a dictionary of dictionaries
# organized like: beatmaps_return["song_name"]: Dictionary = song_name["fishing-1"]: BeatMap = beatmap
func _get_filesystem_beatmaps() -> Dictionary:
	var beatmaps_return := {}
	var music_dir := DirAccess.open("res://music")
	music_dir.list_dir_begin()
	var song_dir_name := music_dir.get_next()
	while song_dir_name != "":
		var song_beatmaps := {}
		var song_dir_reference := DirAccess.open("res://music/" + song_dir_name)
		song_dir_reference.list_dir_begin()
		var song_dir_file := song_dir_reference.get_next()
		while song_dir_file != "":
			if song_dir_file.ends_with(".beat"):
				song_beatmaps[song_dir_file.replace(".beat", "")] = (
					load("res://music/" + song_dir_name + "/" + song_dir_file) as BeatMap
				)
			song_dir_file = song_dir_reference.get_next()
		if !song_beatmaps.is_empty():
			beatmaps_return[song_dir_name] = song_beatmaps
		song_dir_name = music_dir.get_next()
	return beatmaps_return
