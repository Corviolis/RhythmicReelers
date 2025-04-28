extends GutTest

var test_song_path = "res://test/test_assets/music/test_song/"


func test_if_test_song_exist():
	# Check if the test song exists
	assert_true(
		ResourceLoader.exists(test_song_path + "test_song.mp3"),
		"'test-song.mp3' should exist at path: " + test_song_path
	)
	assert_true(
		ResourceLoader.exists(test_song_path + "fishing-1.beat"),
		"'fishing-1.beat' should exist at path: " + test_song_path
	)


func test_get_recognized_extensions():
	var loader = BeatMapLoader.new()
	var extensions = loader._get_recognized_extensions()
	assert_gt(extensions.size(), 0, "Extensions should not be empty")
	assert_has(extensions, "beat", "Extensions should contain 'beat'")


func test_get_resource_script_class():
	var loader = BeatMapLoader.new()
	var classname = loader._get_resource_script_class(test_song_path + "fishing-1.beat")
	assert_eq(classname, "beat_map.gd", "Resource script class should be 'beat_map.gd'")


func test_get_resource_type():
	var loader = BeatMapLoader.new()
	var resource_type = loader._get_resource_type(test_song_path + "fishing-1.beat")
	assert_eq(resource_type, "BeatMap", "Resource type should be 'BeatMap'")


func test_load():
	var loader = BeatMapLoader.new()
	var path = test_song_path + "fishing-1.beat"
	var beat_map = loader._load(path, path, false, ResourceLoader.CACHE_MODE_REUSE)
	assert_ne(beat_map, null, "Beat map should not be null")
	assert_gt(beat_map.get_track_names().size(), 0, "Beat map should have tracks")

	var track = beat_map.get_tracks()[0]
	assert_ne(track, null, "Track should not be null")
