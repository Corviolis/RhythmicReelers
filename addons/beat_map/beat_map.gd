extends Resource
class_name BeatMap

var raw_tracks: Dictionary

class Track:
	var name: String
	var beat_map: Array
	var beat_index: int = 0
	
	class Beat:
		var pos: float
		var len: float
		
		func _init(p, l):
			pos = p
			len = l
	
	func _init(n, map):
		name = n
		beat_map = map
	
	func get_beat():
		return Beat.new(beat_map[beat_index], beat_map[beat_index + 1])

	func next():
		if beat_index + 2 >= len(beat_map):
			beat_index = 0
		else:
			beat_index += 2
		return get_beat()
		
	func reset():
		beat_index = 0

func _init(t):
	raw_tracks = t

func get_track_names():
	return raw_tracks.keys()

func get_track(name: String):
	return Track.new(name, raw_tracks[name])

func get_tracks():
	var tracks = []
	for name in raw_tracks:
		tracks.append(get_track(name))
	return tracks
