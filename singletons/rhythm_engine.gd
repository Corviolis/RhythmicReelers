extends Node

signal session_beat(player_id: int, length: float, track: String, index: int)
signal system_beat
signal system_measure

# see _get_filesystem_beatmaps() documentation
var beatmaps: Dictionary[String, Dictionary] = {}

var song: String
var bpm_list: Array[SongChanges] = []
var next_system_beat_position: float = 0
var beats_left_in_measure: int = 0
var audio = AudioStreamPlayer.new()
var song_position_in_ms: float
var sessions: Array[ThreadSession] = []


class ThreadSession:
	var thread: Thread
	var is_active: bool = false
	var session: Session

	func _init():
		thread = Thread.new()

	func stop():
		is_active = false
		session = null
		thread.wait_to_finish()

	func start(sess: Session, player_id: int):
		is_active = true
		self.session = sess
		thread.start(RhythmEngine._run_session.bind(sess, player_id))


# tracks: array of tracks in a minigame, pulled from the track names in the beatmap midi file
# future_beat_offset: how early to send the beat signal,
#   the minigame will show the beat this far before it is checked
# future_beat_sent: dictionary of bools tracking if the next beat has been sent for a given track
class Session:
	var tracks: Array[BeatMap.Track]
	var future_beat_offset: int
	var future_beat_sent: Dictionary

	func _init(minigame: WindowManager.Minigames, difficulty: int, beat_offset: int):
		future_beat_offset = beat_offset

		var minigame_name: String = WindowManager.Minigames.keys()[minigame]
		var beatmap_name: String = minigame_name.to_lower() + "-" + str(difficulty)
		var beatmap: BeatMap = RhythmEngine.beatmaps[RhythmEngine.song][beatmap_name]
		tracks = beatmap.get_tracks()
		for track in tracks:
			future_beat_sent[track.name] = false
	# Thread class to run the song in a separate thread
	# This is necessary to avoid blocking the main thread
	# while waiting for the song to finish playing


func _ready():
	sessions.resize(4)
	for i in range(sessions.size()):
		sessions[i] = ThreadSession.new()
	beatmaps = _get_filesystem_beatmaps()
	add_child(audio)


func _process(_delta):
	song_position_in_ms = (
		(
			audio.get_playback_position()
			+ AudioServer.get_time_since_last_mix()
			- AudioServer.get_output_latency()
		)
		* 1000
	)
	_report_system_beat()


func _report_system_beat():
	if song_position_in_ms >= next_system_beat_position:
		next_system_beat_position = (
			song_position_in_ms
			+ (calculate_seconds_per_beat(get_current_song_changes(song_position_in_ms).bpm) * 1000)
		)

		beats_left_in_measure -= 1
		if beats_left_in_measure <= 0:
			beats_left_in_measure = (
				get_current_song_changes(song_position_in_ms).time_signature_numerator
			)
			system_measure.emit()

		system_beat.emit()


#===== Helper Functions =====


func calculate_seconds_per_beat(bpm: float) -> float:
	return (60 * 4) / bpm


func calculate_seconds_per_measure(bpm: float, beats_per_measure: int) -> float:
	return calculate_seconds_per_beat(bpm) * beats_per_measure


func get_current_song_changes(song_pos: float) -> SongChanges:
	for i in range(bpm_list.size()):
		if song_pos > bpm_list[i].time:
			return bpm_list[i]
	return bpm_list[bpm_list.size() - 1]


func get_beats_left_in_measure() -> int:
	return beats_left_in_measure


#===== Session Management =====


func start_session(
	player_id: int, minigame: WindowManager.Minigames, difficulty: int, beat_offset: int
):
	sessions[player_id].start(Session.new(minigame, difficulty, beat_offset), player_id)


func end_session(player_id: int):
	sessions[player_id].stop()


func _exit_tree():
	for session in sessions:
		session.stop()
		session.thread.wait_to_finish()


#===== Gameplay / State Management =====


func _run_session(session: Session, player_id: int):
	while sessions[player_id].is_active:
		for track in session.tracks:
			var song_changes = get_current_song_changes(song_position_in_ms)
			var beat: BeatMap.Track.Beat = track.get_next_beat()

			if song_position_in_ms >= beat.pos:
				session.future_beat_sent[track.name] = false
				track.next()
				continue

			if (
				not session.future_beat_sent[track.name]
				and (
					song_position_in_ms
					>= (
						beat.pos
						- (
							calculate_seconds_per_beat(song_changes.bpm)
							* session.future_beat_offset
						)
					)
				)
			):
				session_beat.emit.call_deferred(player_id, beat.len, track.name, beat.index)
				session.future_beat_sent[track.name] = true


# returns time to beat in ms, negative if after the beat
# BUG: the returned hit time is very irregular and has a wide margin of error
# BUG: is beat_offset really needed here?
func hit(player_id: int, track_name: String, beat_index: int, beat_offset: int) -> float:
	for track in sessions[player_id].session.tracks:
		if track.name == track_name:
			return track.get_time_to_beat(
				beat_index,
				(
					song_position_in_ms
					- (
						beat_offset
						* calculate_seconds_per_beat(
							get_current_song_changes(song_position_in_ms).bpm
						)
						* 1000
					)
				)
			)
	push_error("Hit called on non-existent track %s" % track_name)
	return 0.0


func play_song(song_name: String, path: String = "res://music/songs/"):
	song = song_name
	bpm_list = _get_csv_bpm(song_name, path)
	audio.stream = load(path + song_name + "/" + song_name + ".mp3")
	audio.play()


#===== File Reading =====


# returns a dictionary of dictionaries
# organized like: beatmaps_return["song_name"]: Dictionary =
#   song_name["fishing-1"]: BeatMap = beatmap
func _get_filesystem_beatmaps(
	path: String = "res://music/songs/"
) -> Dictionary[String, Dictionary]:
	var beatmaps_return: Dictionary[String, Dictionary] = {}
	var music_dir := DirAccess.open(path)
	music_dir.list_dir_begin()
	var song_dir_name := music_dir.get_next()
	while song_dir_name != "":
		var song_beatmaps := {}
		var song_dir_reference := DirAccess.open(path + song_dir_name)
		song_dir_reference.list_dir_begin()
		var song_dir_file := song_dir_reference.get_next()
		while song_dir_file != "":
			if song_dir_file.ends_with(".beat"):
				song_beatmaps[song_dir_file.replace(".beat", "")] = (
					load(path + song_dir_name + "/" + song_dir_file) as BeatMap
				)
			song_dir_file = song_dir_reference.get_next()
		if !song_beatmaps.is_empty():
			beatmaps_return[song_dir_name] = song_beatmaps
		song_dir_name = music_dir.get_next()
	return beatmaps_return


class SongChanges:
	var time: float
	var bpm: float
	var time_signature_numerator: int
	var time_signature_denominator: int

	func _init(song_time: float, bpm_input: float, numerator: int, denominator: int):
		self.time = song_time
		self.bpm = bpm_input
		self.time_signature_numerator = numerator
		self.time_signature_denominator = denominator


func _get_csv_bpm(song_name: String, path: String = "res://music/songs/") -> Array[SongChanges]:
	var result: Array[SongChanges] = []
	var file_path = path + song_name + "/bpm.csv"

	# Open the file
	if ResourceLoader.exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		file.get_line()  # Skip the header line

		# Read the file line by line
		while file.get_position() < file.get_length():
			var columns = file.get_csv_line()
			result.append(
				SongChanges.new(
					columns[0].to_float(),
					columns[1].to_float(),
					columns[2].to_int(),
					columns[3].to_int()
				)
			)

		file.close()
	else:
		printerr("BPM file does not exist: %s" % file_path)

	return result
