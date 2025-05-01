extends GutTest

var fishing_minigame: Minigame
var rhythm_engine: RhythmEngine
var test_song_dir = "res://test/test_assets/music/"

# TODO: this test creates 2 orphans, attempt to fix this?


func before_each():
	rhythm_engine = load("res://singletons/rhythm_engine.gd").new()
	add_child(rhythm_engine)
	rhythm_engine.play_song("test_song", test_song_dir)
	rhythm_engine.beatmaps = rhythm_engine._get_filesystem_beatmaps(test_song_dir)

	assert(ResourceLoader.exists("res://scenes/minigames/fishing/fishing.tscn"))
	fishing_minigame = (
		load("res://scenes/minigames/fishing/fishing.tscn").instantiate() as Minigame
	)
	var player := Player.new()
	player.player_id = 1
	PlayerManager.player_data[player.player_id] = {
		"device": -1, "character_index": 0, "multiplayer_authority": 1
	}
	fishing_minigame.rhythm_engine = rhythm_engine
	fishing_minigame.player_id = player.player_id
	fishing_minigame.playing = true
	add_child(fishing_minigame)


func after_each():
	fishing_minigame.queue_free()
	rhythm_engine.queue_free()
	PlayerManager.player_data.clear()


func test_onbeat():
	assert_eq(len(fishing_minigame.beats), 0, "Fishing minigame should have no beats initially")
	fishing_minigame.on_beat(1, 1, "Electric Piano", 0)
	assert_eq(
		len(fishing_minigame.beats), 1, "Fishing minigame should have one beat after on_beat()"
	)


func test_beat():
	assert_null(fishing_minigame._beat(), "_beat() should return null if no beats are set")
	fishing_minigame.on_beat(1, 1, "Electric Piano", 0)
	assert(len(fishing_minigame.beats) == 1)  # technically part of test_onbeat() but sanity check
	assert_typeof(
		fishing_minigame._beat(),
		TYPE_FLOAT,
		"_beat() should return the distance to the closest beat if there are beats"
	)
	assert_eq(len(fishing_minigame.beats), 0, "Fishing minigame should have no beats after _beat()")
