extends GutTest

var fishing_minigame: Minigame
var test_song_dir = "res://test/test_assets/music/"

# TODO: this test creates 2 orphans, attempt to fix this?


func before_each():
	RhythmEngine.beatmaps = RhythmEngine._get_filesystem_beatmaps(test_song_dir)
	RhythmEngine.play_song("test_song", test_song_dir)
	assert(ResourceLoader.exists("res://scenes/minigames/fishing/fishing.tscn"))
	fishing_minigame = (
		load("res://scenes/minigames/fishing/fishing.tscn").instantiate() as Minigame
	)
	var player := Player.new()
	player.player_id = 1
	PlayerManager.player_data[player.player_id] = {
		"device": -1, "character_index": 0, "multiplayer_authority": 1
	}
	fishing_minigame.player_id = player.player_id
	add_child_autofree(fishing_minigame)


func test_onbeat():
	assert_eq(len(fishing_minigame.beats), 0, "Fishing minigame should have no beats initially")
	fishing_minigame.on_beat(1, 1, "Electric Piano")
	assert_eq(
		len(fishing_minigame.beats), 1, "Fishing minigame should have one beat after on_beat()"
	)


func test_beat():
	assert_null(fishing_minigame._beat(), "_beat() should return null if no beats are set")
	fishing_minigame.on_beat(1, 1, "Electric Piano")
	assert(len(fishing_minigame.beats) == 1)  # technically part of test_onbeat() but sanity check
	assert_typeof(
		fishing_minigame._beat(),
		TYPE_FLOAT,
		"_beat() should return the distance to the closest beat if there are beats"
	)
	assert_eq(len(fishing_minigame.beats), 0, "Fishing minigame should have no beats after _beat()")
