extends Node

signal future_beat(player_id: int, length: float)
signal current_beat(player_id: int, length: float)

var audio = AudioStreamPlayer.new()

var delay: float
var song_position: float
var beatmaps: Dictionary
var sessions = []

class Session:
	var tracks: Array[Track]
	
	class Track:
		var beat_map: Array[float]
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
	
	var chars_dir = DirAccess.open("res://music/beatmaps")
	chars_dir.list_dir_begin()
	var folder = chars_dir.get_next()
	
	while folder != "":
		var assets = {}
		var char_dir = DirAccess.open("res://music/beatmaps" + folder)
		char_dir.list_dir_begin()
		var asset = char_dir.get_next()
		
		while asset != "" && asset.ends_with(".beat"):
			var all_bytes: PackedByteArray = FileAccess.get_file_as_bytes("res://music/beatmaps/" + folder + "/" + asset)
			var bytes: PackedByteArray
			var track_offset = 0
			
			# Loop through all the tracks
			for i in range(all_bytes.decode_u8(0)):
				var end = bytes.find(0x0a)
				bytes = all_bytes.slice(track_offset, end - 1)
				track_offset += end
				# Track name
				var offset = bytes.find(0x0b)
				var name = bytes.slice(0, offset - 1).get_string_from_utf8()
				offset += 1
				# Track data
				var beat_map: Array
				while end > offset:
					beat_map.append(bytes.decode_float(offset))
					offset += 4
				assets[name] = beat_map
			asset = char_dir.get_next()
		
		beatmaps[folder] = assets
		folder = chars_dir.get_next()
		
	audio.play()

func _process(_delta):
	song_position = audio.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

	for id in range(sessions.size()):
		var session = sessions[id]
		if session == null:
			continue
		
		for track in session.tracks:
			# Scan for position in beatmap
			var beat = track.get_beat()
			while song_position > beat[0]:
				beat = track.next_beat()
			
			if song_position >= beat[0]:
				current_beat.emit(id, beat[1])
				track.next_beat()
				continue

			if !track.beat_sent && GlobalUtils.equal_approx(beat[0] - track.future_beat_offset, song_position):
				future_beat.emit(id, beat[1])
				track.future_beat_sent = true

func start_session(player_id: int, beat_map):
	sessions[player_id] = beat_map

func end_session(player_id: int):
	sessions[player_id] = null
