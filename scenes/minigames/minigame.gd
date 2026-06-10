class_name Minigame
extends Node2D

# var rhythm_engine: RhythmEngine
var player_id: int
var input: DeviceInput
var minigame_window: MinigameWindow
var minigame_station: NodePath
var score_label: Label


func _enter_tree() -> void:
	set_multiplayer_authority(PlayerManager.get_player_authority(player_id))
	minigame_window = get_parent() as MinigameWindow


func _process(delta: float) -> void:
	_handle_input(delta)


func _handle_input(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if input.is_action_just_pressed("exit"):
		_exit_minigame()
	if input.is_action_just_pressed("beat"):
		_beat()


# Check how close the oldest alive beat is to the target
func _beat() -> void:
	pass


func _exit_minigame() -> void:
	PlayerManager.stop_player_minigame(player_id)
	close_window.rpc()
	(get_node(minigame_station) as StationInteractable).close_interact.bind(player_id).rpc()


@rpc("any_peer", "call_local", "reliable")
func close_window() -> void:
	if minigame_window == null:
		queue_free()
	else:
		minigame_window.queue_free()

# How the minigames work:
# Fishing: highway bottom to top mimicking fishing
# Cutting: highway right to left with the hit triggering a cutting animation
# Shooting: circles around crosshair that move into the existing circle
#	rhythm controlled by what bullets are loaded
#	remember to add animation to crosshair on fire + sound design
#	multiple imperfect timings cause you to slowly overheat?
#	can deliberately vent? heat impacts damage? resource you need to manage
#	maybe venting heat has an aoe effect around your ship
# Reloading: bullets have a rhythm you need to hit, different for each bullet
#	-> there is a highway leading away from the hit line rather than towards it
#	bullets have a charge and a cooldown, can only add so many of a type at a time
#	*or*
#	there are three tracks and you can load multiple bullets at once by following all tracks
#	*or*
#	setting bullets up and working your way up to harder but more rewarding bullets?

# for the fishing and cutting minigames, one measure = one finished item

# Bullets travel AWAY from the judgment line.
# You initiate bullets with a hit.
# While traveling, they require follow-up inputs.
# Different ammo types have different rhythm signatures.
# Multiple lanes/chambers allow parallel loading.
#
# So skilled players can:
#
# preload complex ammo,
# juggle several bullets simultaneously,
# create rhythm “polyrhythms”.

# Instead of bullets being individual notes, they’re recipes.
#
# Example:
#
# Basic bullet = single beat
# Piercing = syncopated triplet
# Explosive = alternating lanes
# Electric = hold-release-hold
#
# Reloading becomes:
#
# perform the manufacturing rhythm.
#
# This is especially strong if shooting consumes special ammo quickly.
#
# The fun loop becomes:
#
# earn downtime,
# craft advanced rounds,
# spend them in combat.
#
# That creates tension:
#
# “Do I safely make weak ammo or risk harder patterns for strong ammo?”
