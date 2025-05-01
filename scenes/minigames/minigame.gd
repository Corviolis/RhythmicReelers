class_name Minigame
extends Node2D

var rhythm_engine: RhythmEngine
var player_id: int
var input: DeviceInput


func _enter_tree():
	if rhythm_engine == null:
		rhythm_engine = RhythmEngine
	set_multiplayer_authority(PlayerManager.get_player_authority(player_id))
