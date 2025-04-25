class_name BeatMap
extends Resource

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

	func get_beat() -> Beat:
		return Beat.new(beat_map[beat_index], beat_map[beat_index + 1])

	func get_prev_beat() -> Beat:
		if beat_index == 0:
			return get_beat()
		return Beat.new(beat_map[beat_index - 2], beat_map[beat_index - 1])

	func get_time_to_closest(time) -> float:
		var time_to_next: float = get_beat().pos - time
		var time_to_prev: float = get_prev_beat().pos - time
		if abs(time_to_next) < abs(time_to_prev):
			return time_to_next
		return time_to_prev

	func next() -> Beat:
		if beat_index + 2 >= len(beat_map) - 1:
			reset()
		else:
			beat_index += 2
		return get_beat()

	func reset():
		beat_index = 0


func _init(t):
	raw_tracks = t


func get_track_names() -> Array:
	return raw_tracks.keys()


func get_track(name: String) -> Track:
	return Track.new(name, raw_tracks[name])


func get_tracks() -> Array:
	var tracks = []
	for name in raw_tracks:
		tracks.append(get_track(name))
	return tracks
