class_name Minigame
extends Node2D

# var rhythm_engine: RhythmEngine
var player_id: int
var input: DeviceInput
var minigame_window: MinigameWindow


func _enter_tree():
	set_multiplayer_authority(PlayerManager.get_player_authority(player_id))
	minigame_window = get_parent() as MinigameWindow
