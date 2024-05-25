extends Node

signal future_beat(player_id: int, length: float, name: String)
signal current_beat(player_id: int, length: float, name: String)

static var beat_maps: Dictionary
var audio = AudioStreamPlayer.new()
var delay: float
var song_position: float
var sessions = []

class Session:
	var tracks: Dictionary
	
	func _init(map: String):
		tracks = RhythmEngine.beat_maps[map]
	
	class Track:
		var beat_map: Array[int]
		var beat_index: int = 0
		var future_beat_offset: int
		var future_beat_sent: bool = false

		func get_beat():
			return [beat_map[beat_index], beat_map[beat_index + 1]]

		func next_beat():
			beat_index += 1
			future_beat_sent = false
			return get_beat()
			
		func reset():
			beat_index = 0
			future_beat_sent = false

func _ready():
	add_child(audio)
	delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	
	var music_dir = DirAccess.open("res://music/beatmaps")
	music_dir.list_dir_begin()
	var folder = music_dir.get_next()
	
	while folder != "":
		var maps = {}
		var beat_dir = DirAccess.open("res://music/beatmaps/" + folder)
		beat_dir.list_dir_begin()
		var asset = beat_dir.get_next()
		
		while asset != "" && asset.ends_with(".beat"):
			var all_bytes: PackedByteArray = FileAccess.get_file_as_bytes("res://music/beatmaps/" + folder + "/" + asset)
			var track_offset = 1
			
			# Loop through all the tracks
			for i in range(all_bytes.decode_u8(0)):
				var end = all_bytes.find(0x0b)
				var bytes = all_bytes.slice(track_offset, end)
				track_offset += end
				
				# Track name
				var offset = bytes.find(0x0a)
				var track_name = bytes.slice(0, offset).get_string_from_utf8()
				offset += 1
				
				# Track data
				var beat_map = []
				while end - 1 > offset:
					beat_map.append(bytes.decode_u32(offset))
					offset += 4
				maps[track_name] = beat_map
			asset = beat_dir.get_next()
		
		beat_maps[folder] = maps
		folder = music_dir.get_next()
	
	audio.play()

func _process(_delta):
	song_position = audio.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

	for id in range(sessions.size()):
		var session = sessions[id]
		if session == null:
			continue
		
		for track_name in session.tracks:
			var track = session.tracks[track_name]
			# Scan for position in beatmap
			var beat = track.get_beat()
			while song_position > beat[0]:
				beat = track.next_beat()
			
			if song_position >= beat[0]:
				current_beat.emit(id, beat[1], track_name)
				track.next_beat()
				continue

			if !track.beat_sent && GlobalUtils.equal_approx(beat[0] - track.future_beat_offset, song_position):
				future_beat.emit(id, beat[1], track_name)
				track.future_beat_sent = true

func start_session(player_id: int, beat_map):
	sessions[player_id] = beat_map

func end_session(player_id: int):
	sessions[player_id] = null
