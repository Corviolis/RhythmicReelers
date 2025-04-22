extends GutTest


func before_each():
	pass


func test_ready():
	# Check if the beat maps are loaded correctly
	assert(RhythmEngine.beat_maps.size() > 0)

	# Check if the audio stream is set up correctly
	assert(RhythmEngine.audio.stream != null)

	# Check if the song position is initialized to 0
	assert(RhythmEngine.song_position == 0)

# class TestSession:
# 	extends GutTest
#
# 	func test_init():
# 		# Create a new session with a beat map and difficulty
# 		var session = RhythmEngine.Session.new("test_map", 1, 5)
# 		assert(session != null)
# 		assert(session.future_beat_offset == 5)
# 		assert(session.tracks.size() > 0)
