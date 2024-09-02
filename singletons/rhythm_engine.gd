extends Node

signal beat_sig(player_id: int, length: float, track: String)

var beat_maps: Dictionary
var song: String
var audio = AudioStreamPlayer.new()
var song_position: float
var sessions = []

class Session:
	var tracks: Array
	var future_beat_offset: int
	var future_beat_sent: Dictionary
	
	func _init(map: String, difficulty: int, offset: int):
		future_beat_offset = offset
		
		var beat_map = RhythmEngine.beat_maps[RhythmEngine.song][str(map, "-", difficulty)]
		tracks = beat_map.get_tracks()
		for track in tracks:
			future_beat_sent[track.name] = false
			

func _ready():
	sessions.resize(4)
	
	var music_dir = DirAccess.open("res://music")
	music_dir.list_dir_begin()
	var folder = music_dir.get_next()
	
	while folder != "":
		var maps = {}
		var beat_dir = DirAccess.open("res://music/" + folder)
		beat_dir.list_dir_begin()
		var asset = beat_dir.get_next()
		
		while asset != "":
			if asset.ends_with(".beat"):
				maps[asset.replace(".beat", "")] = load("res://music/" + folder + "/" + asset) as BeatMap
			asset = beat_dir.get_next()
		
		if !maps.is_empty():
			beat_maps[folder] = maps
		folder = music_dir.get_next()
	
	add_child(audio)
	song = "song"
	audio.stream = load("res://music/" + song + "/" + song + ".mp3")
	audio.play()

func _process(_delta):
	song_position = (audio.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()) * 1000
	
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

			if !session.future_beat_sent[track.name] && song_position >= beat.pos - session.future_beat_offset:
				beat_sig.emit(id, beat.len, track.name)
				session.future_beat_sent[track.name] = true

func start_session(player_id: int, map: String, difficulty: int, offset: int):
	sessions[player_id] = Session.new(map, difficulty, offset)

func end_session(player_id: int):
	sessions[player_id] = null

func hit(player_id: int, track_name: String, accuracy: float):
	for track in sessions[player_id].tracks:
		if track.name == track_name:
			print(track.get_time_to_closest(song_position))
			return track.get_time_to_closest(song_position) - accuracy <= 0
	
