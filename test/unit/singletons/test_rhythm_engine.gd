extends GutTest


func test_get_filesystem_beatmaps():
	# Check if the beat maps are loaded correctly
	var beat_maps = RhythmEngine._get_filesystem_beatmaps()
	assert_gt(beat_maps.size(), 0, "Beat maps should not be empty")

	# Check if the beat maps contain the expected keys
	assert_has(beat_maps, "test_song", "Beat maps should contain 'test_song'")
	assert_has(beat_maps["test_song"], "fishing-1", "'test_song' should contain 'fishing-1'")

	# Check if the beat map has the expected tracks
	var test_map = beat_maps["test_song"]["fishing-1"]
	assert(test_map.get_track_names().size() > 0)


func test_play_song():
	# Check if the song is played correctly
	RhythmEngine.play_song("test_song")
	assert_eq(RhythmEngine.song, "test_song", "Song should be 'test_song'")

	# Check if the audio stream player is playing the correct song
	var audio = RhythmEngine.audio
	assert_eq(
		audio.get_stream().resource_path,
		"res://music/test_song/test_song.mp3",
		"Audio stream should be 'test_song'"
	)


func test_start_session():
	# Check session is not started
	var session = RhythmEngine.sessions[0].session
	assert_eq(session, null)

	# Check if a session is started correctly
	RhythmEngine.start_session(0, WindowManager.Minigames.Fishing, 1, 5)
	session = RhythmEngine.sessions[0].session
	assert_ne(session, null, "Session should not be null")
	assert_eq(session.future_beat_offset, 5, "Session future beat offset should be 5")

	# Check if the session has tracks
	assert_gt(session.tracks.size(), 0, "Session should have tracks")


func test_hit():
	# Check if a hit is registered correctly
	RhythmEngine.play_song("test_song")
	RhythmEngine.start_session(0, WindowManager.Minigames.Fishing, 1, 5)
	var session = RhythmEngine.sessions[0].session
	var track_name = session.tracks[0].name

	var result_hit = RhythmEngine.hit(0, track_name)
	assert_eq(result_hit, 0, "Hit time should be 0 if on beat")
	print(result_hit)

	await wait_seconds(0.5)
	var result_fail = RhythmEngine.hit(0, track_name)
	print(result_fail)
	assert_lt(result_fail, 0, "Hit should be negative if after beat")
	assert_almost_eq(
		result_fail, -300, 50, "I don't know why but the hit is negative 300ms despite waiting 0.5s"
	)


func test_process():
	# Check if the process function works correctly
	RhythmEngine.start_session(0, WindowManager.Minigames.Fishing, 1, 5)

	# Check if the future beat signal is emitted correctly
	watch_signals(RhythmEngine)
	await wait_seconds(RhythmEngine._calculate_seconds_per_beat(RhythmEngine.bpm_list[0].bpm))
	assert_signal_emitted(RhythmEngine, "system_beat", "System beat signal should be sent")
	assert_signal_emitted(RhythmEngine, "player_beat", "Player beat signal should be sent")


func test_end_session():
	# Check if a session is ended correctly
	RhythmEngine.end_session(0)
	var session = RhythmEngine.sessions[0]
	assert_eq(session.session, null, "Session should be null")
	assert_false(session.is_active, "Session is_active should be false")
