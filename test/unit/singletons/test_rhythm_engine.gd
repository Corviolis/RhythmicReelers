extends GutTest

var test_song_dir = "res://test/test_assets/music/"
var rhythm_engine: RhythmEngine


func before_each():
	rhythm_engine = load("res://singletons/rhythm_engine.gd").new()
	add_child_autoqfree(rhythm_engine)
	rhythm_engine.play_song("test_song", test_song_dir)
	rhythm_engine.beatmaps = rhythm_engine._get_filesystem_beatmaps(test_song_dir)


func test_get_filesystem_beatmaps():
	# Check if the beat maps are loaded correctly
	var beat_maps = rhythm_engine._get_filesystem_beatmaps(test_song_dir)
	assert_gt(beat_maps.size(), 0, "Beat maps should not be empty")

	# Check if the beat maps contain the expected keys
	assert_has(beat_maps, "test_song", "Beat maps should contain 'test_song'")
	assert_has(beat_maps["test_song"], "fishing-1", "'test_song' should contain 'fishing-1'")

	# Check if the beat map has the expected tracks
	var test_map = beat_maps["test_song"]["fishing-1"]
	assert_has(test_map.get_track_names(), "Electric Piano", "Track names should not be empty")


func test_get_csv_bpm():
	var bpm_changes := rhythm_engine._get_csv_bpm("test_song", test_song_dir)
	assert_eq(bpm_changes.size(), 3)

	assert_eq(bpm_changes[0].bpm, 120)
	assert_eq(bpm_changes[0].time, 0)
	assert_eq(bpm_changes[0].time_signature_numerator, 4)
	assert_eq(bpm_changes[0].time_signature_denominator, 4)

	assert_eq(bpm_changes[1].bpm, 100)
	assert_eq(bpm_changes[1].time, 8)
	assert_eq(bpm_changes[1].time_signature_numerator, 5)
	assert_eq(bpm_changes[1].time_signature_denominator, 8)

	assert_eq(bpm_changes[2].bpm, 170)
	assert_eq(bpm_changes[2].time, 15.5)
	assert_eq(bpm_changes[2].time_signature_numerator, 5)
	assert_eq(bpm_changes[2].time_signature_denominator, 8)


func test_play_song():
	# Check if the song is played correctly
	assert_eq(rhythm_engine.song, "test_song", "Song should be 'test_song'")

	# Check if the audio stream player is playing the correct song
	var audio = rhythm_engine.audio
	assert_eq(
		audio.get_stream().resource_path,
		test_song_dir + "test_song/test_song.mp3",
		"Audio stream should be 'test_song'"
	)


func test_start_session():
	# Check session is not started
	var session = rhythm_engine.sessions[0].session
	assert_eq(session, null)

	# Check if a session is started correctly
	rhythm_engine.start_session(0, WindowManager.Minigames.FISHING, 1, 5)
	session = rhythm_engine.sessions[0].session
	assert_ne(session, null, "Session should not be null")
	assert_eq(session.future_beat_offset, 5, "Session future beat offset should be 5")

	# Check if the session has tracks
	assert_gt(session.tracks.size(), 0, "Session should have tracks")


func test_hit():
	# Check if a hit is registered correctly
	rhythm_engine.play_song("test_song", test_song_dir)
	rhythm_engine.start_session(0, WindowManager.Minigames.FISHING, 1, 5)
	var session = rhythm_engine.sessions[0].session
	var track_name = session.tracks[0].name

	var result_hit = rhythm_engine.hit(0, track_name, 0, 0, 0)
	assert_eq(result_hit, 0.0, "Hit time should be 0 if on beat")

	var result_fail = rhythm_engine.hit(0, track_name, 0, 0, 300)
	print("Result fail: ", result_fail)
	assert_eq(result_fail, -300, "Hit time should be -300 if delayed by 300ms")


func test_end_session():
	# Check if a session is ended correctly
	rhythm_engine.start_session(0, WindowManager.Minigames.FISHING, 1, 5)
	rhythm_engine.end_session(0)
	var session = rhythm_engine.sessions[0]
	assert_eq(session.session, null, "Session should be null")
	assert_false(session.is_active, "Session is_active should be false")


func test_calculate_duration_of_next_x_measures():
	var duration = rhythm_engine.calculate_duration_of_next_x_measures(0, 3)
	assert_almost_eq(duration, 27, 0.1)
