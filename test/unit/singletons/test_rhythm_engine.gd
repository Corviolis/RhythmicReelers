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
	# Check if a session is started correctly
	RhythmEngine.start_session(0, WindowManager.Minigames.Fishing, 1, 5)
	var session = RhythmEngine.sessions[0]
	assert_ne(session, null, "Session should not be null")
	assert_eq(session.future_beat_offset, 5, "Session future beat offset should be 5")

	# Check if the session has tracks
	assert_gt(session.tracks.size(), 0, "Session should have tracks")


func test_end_session():
	# Check if a session is ended correctly
	RhythmEngine.end_session(0)
	var session = RhythmEngine.sessions[0]
	assert_eq(session, null, "Session should be null")


func test_hit():
	# Check if a hit is registered correctly
	RhythmEngine.start_session(0, WindowManager.Minigames.Fishing, 1, 5)
	var session = RhythmEngine.sessions[0]
	var track_name = session.tracks[0].name
	var accuracy = 0.1

	var time_to_closest = session.tracks[0].get_time_to_closest(RhythmEngine.song_position)
	assert_eq(time_to_closest - accuracy <= 0, true, "Hit accuracy should be within range")

	var result_hit = RhythmEngine.hit(0, track_name, accuracy)
	assert_eq(result_hit, true, "Hit should be successful if accuracy is within range")

	await wait_seconds(0.2)
	var result_fail = RhythmEngine.hit(0, track_name, accuracy)
	assert_eq(result_fail, false, "Hit should be unsuccessful if time is incorrect")
