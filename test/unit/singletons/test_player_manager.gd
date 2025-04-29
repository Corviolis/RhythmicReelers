extends GutTest


func test_catalogue_player_assets():
	PlayerManager.character_assets = []
	PlayerManager.catalogue_player_assets("res://test/test_assets/characters/")

	assert_eq(
		PlayerManager.get_character_asset_count(), 2, "PlayerManager should read 2 character assets"
	)
	assert_eq(
		PlayerManager.get_character_assets(0).size(),
		2,
		"PlayerManager should have 2 assets in happy_guy/"
	)


class TestPlayerAssets:
	extends GutTest

	func before_each():
		PlayerManager.player_data = {}

	func test_join_game():
		assert_eq(
			PlayerManager.get_player_count(), 0, "PlayerManager should have 0 players at start"
		)
		watch_signals(PlayerManager)
		PlayerManager._join_game(-1, 1, 0)
		assert_eq(PlayerManager.get_player_count(), 1, "PlayerManager should have 1 player")
		assert_eq(PlayerManager.get_player_indexes()[0], 1, "PlayerManager should have player 1")
		assert_eq(PlayerManager.get_player_device(1), -1, "PlayerManager should have device 0")
		assert_signal_emitted_with_parameters(PlayerManager, "player_joined", [1, 1])

	func test_leave():
		PlayerManager._join_game(-1, 1, 0)
		assert_eq(PlayerManager.get_player_count(), 1, "PlayerManager should have 1 player")
		watch_signals(PlayerManager)
		PlayerManager.leave(1)
		assert_eq(PlayerManager.get_player_count(), 0, "PlayerManager should have 0 players")
		assert_signal_emitted_with_parameters(PlayerManager, "player_left", [1])
