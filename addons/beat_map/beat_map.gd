extends Resource
class_name BeatMap

var raw_tracks: Dictionary

class Track:
	var name: String
	var beat_map: Array[int]
	var beat_index: int = 0
	
	class Beat:
		var pos: int
		var len: int
		
		func _init(p, l):
			pos = p
			len = l
	
	func _init(n, map):
		name = n
		beat_map = map
	
	func get_beat():
		return Beat.new(beat_map[beat_index], beat_map[beat_index + 1])

	func next():
		beat_index += 1
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
