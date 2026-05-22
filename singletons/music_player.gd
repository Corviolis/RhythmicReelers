extends Node

var audio_player := AudioStreamPlayer.new()
var beat_map: BeatMap
var song_position: float

signal update_song_position(time: float)


func _ready() -> void:
	add_child(audio_player)
	play_song("song_2")
	beat_map = parse_beatmap("song_2")


func _process(_delta: float) -> void:
	var time := audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	song_position = time
	update_song_position.emit(time)


func play_song(song_name: String, path: String = "res://music/songs/") -> void:
	audio_player.stream = load(path + song_name + "/" + song_name + ".wav")
	audio_player.play()


func parse_beatmap(song_name: String, path: String = "res://music/songs/") -> BeatMap:
	var file := FileAccess.open(path + song_name + "/chart.json", FileAccess.READ)
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error != OK:
		printerr("ERROR WHILE PARSING BEATMAP JSON")

	return BeatMap.parse_beatmap(json)


class BeatMap:
	var tracks: Dictionary[String, Track]

	static func parse_beatmap(json: JSON) -> BeatMap:
		var ret := BeatMap.new()
		var raw_beatmap: Variant = json.data
		Conductor.bpm = raw_beatmap["bpm"]
		for name: String in raw_beatmap["groups"]:
			ret.tracks[name] = Track.new()
			for note_raw: Dictionary in raw_beatmap["groups"][name]:
				var note := Note.new(note_raw["time"] as float, note_raw["duration"] as float)
				ret.tracks[name].notes.append(note)
		return ret

	class Track:
		var name: String
		var notes: Array[Note]

	class Note:
		var time: float
		var duration: float

		func _init(time_in: float, duration_in: float = 0) -> void:
			time = time_in
			duration = duration_in
