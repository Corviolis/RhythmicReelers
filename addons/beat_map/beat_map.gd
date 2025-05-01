class_name BeatMap
extends Resource

var raw_tracks: Dictionary


class Track:
	var name: String
	var beat_map: Array
	var current_beat_index: int = 0

	class Beat:
		var pos: float
		var len: float
		var index: int

		func _init(p, l, i):
			pos = p
			len = l
			index = i

	func _init(n, map):
		name = n
		beat_map = map

	# BUG: Occasionally causes a crash??? Cannot inherit from a virtual class
	func get_next_beat() -> Beat:
		return Beat.new(
			beat_map[current_beat_index], beat_map[current_beat_index + 1], current_beat_index
		)

	func get_beat_by_index(beat_index: int) -> Beat:
		return Beat.new(beat_map[beat_index], beat_map[beat_index + 1], beat_index)

	func get_time_to_beat(beat_index: int, time: float) -> float:
		return beat_map[beat_index] - time

	func next() -> void:
		if current_beat_index + 2 >= len(beat_map) - 1:
			reset()
		else:
			current_beat_index += 2

	func reset():
		current_beat_index = 0


func _init(t):
	raw_tracks = t


func get_track_names() -> Array:
	return raw_tracks.keys()


func get_track(name: String) -> Track:
	return Track.new(name, raw_tracks[name])


func get_tracks() -> Array[Track]:
	var tracks: Array[Track] = []
	for name in raw_tracks:
		tracks.append(get_track(name))
	return tracks
