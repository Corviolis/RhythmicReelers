extends CharacterBody2D

enum States { NULL, MOVING, SEARCHING, APPROACHING, ATTACKING, FLEEING }
var current_state: States = States.NULL
var wait_spot: WaitSpot = null
var attack_slot: AttackSpot = null

@onready var pathfinding_component: PathfindingComponent = %PathfindingComponent
@onready var attack_component: AttackComponent = %AttackComponent
@onready var avoid_minigame_component: AvoidMinigameComponent = %AvoidMinigameComponent
@onready var boat: Node2D = get_tree().get_root().get_child(-1).get_child(0)

# NOTE: enemies can attack each other? fighting over food, it's like a feeding frenzy
# NOTE: enemies are semi-permenant, but there's large waves
# NOTE: normally, predators don't fight each other over prey
#	- start when neighbour count (or waiting count) reaches a certain point
#	- can just be animation rather than actual friendly fire damage
# NOTE: animals are smart enough to realize when a skirmish isn't worth it (risk/reward)
# NOTE: imps scatter when larger predators arrive
# NOTE: territory is a very important consideration, the only species that lives in a slow
#	predator's territory are those fast enough to evade it

# NOTE: attack slots on boat, an enemy will first move to a nearby waiting slot, and then from there a waiting slot owns a number of attack slots and manages whether they're in use or not.
# NOTE: if there are no attack slots available, ai will move around to adjacent wait slots looking for an open space.
# NOTE: prefer the adjacent waiting slot with less units
#	(?) additionally prefer moving in the same direction
# NOTE: imp has a wait timer, on timeout just try to push into a spot anyways ?


func _ready() -> void:
	change_state(States.MOVING)


func _exit_tree() -> void:
	if wait_spot:
		wait_spot.remove_occupant()
	if attack_slot:
		attack_slot.remove_occupant()


func _enter_waiting_room() -> void:
	if wait_spot:
		wait_spot.remove_occupant()
	if attack_slot:
		attack_slot.remove_occupant()
	var closest_wait_spot := _get_closest_valid_waiting_spot()
	var possible_attack_slot := closest_wait_spot.get_available_slot()
	if possible_attack_slot:
		_target_attack_spot(possible_attack_slot)
		return
	change_state(States.SEARCHING)
	wait_spot = closest_wait_spot
	wait_spot.add_occupant()
	pathfinding_component.set_target(wait_spot.global_position)


func _target_attack_spot(target: AttackSpot) -> void:
	attack_slot = target
	attack_slot.add_occupant()
	pathfinding_component.set_target(attack_slot.global_position)
	change_state(States.APPROACHING)
	attack_slot.covered.connect(func() -> void: change_state(States.MOVING))


# WARN: change to index before full release
func _get_closest_valid_waiting_spot() -> WaitSpot:
	var enemyWaitSpots: Array[WaitSpot]
	enemyWaitSpots.assign(boat.get_node("Slots").get_children())
	enemyWaitSpots.sort_custom(
		func(a: WaitSpot, b: WaitSpot) -> bool:
			return (
				global_position.distance_to(a.global_position)
				< global_position.distance_to(b.global_position)
			)
	)
	var index := enemyWaitSpots.find_custom(func(a: WaitSpot) -> bool: return not a.is_full)
	if index > 2:
		index = randi() % 3
	return enemyWaitSpots[index]


func _reached_wait_spot() -> void:
	var possible_attack_slot := wait_spot.get_available_slot()
	if possible_attack_slot:
		attack_slot = possible_attack_slot
		attack_slot.add_occupant()
		pathfinding_component.set_target(attack_slot.global_position)
		change_state(States.APPROACHING)
		return
	var neighbour := wait_spot.get_most_available_neighbour()
	wait_spot.remove_occupant()
	neighbour.add_occupant()
	wait_spot = neighbour
	pathfinding_component.set_target(neighbour.global_position)


func _on_pathfinding_reached() -> void:
	print(States.find_key(current_state))
	match current_state:
		States.MOVING:
			change_state(States.SEARCHING)
		States.SEARCHING:
			_reached_wait_spot()
		States.APPROACHING:
			change_state(States.ATTACKING)
		_:
			push_error("Unexpected state %s" % current_state)


func _on_leave_attack_range() -> void:
	change_state(States.MOVING)


func _on_enter_minigame_window() -> void:
	pass


func _on_leave_minigame_window() -> void:
	pass


func change_state(state: States) -> void:
	match state:
		States.MOVING:
			current_state = States.MOVING
			_enter_waiting_room()
		States.SEARCHING:
			current_state = States.SEARCHING
		States.APPROACHING:
			current_state = States.APPROACHING
		States.ATTACKING:
			if avoid_minigame_component.is_inside_window() or not attack_component.is_in_range:
				change_state(States.MOVING)
				return
			current_state = States.ATTACKING
			print("attack state")
			attack_component.start_attacking()
		_:
			push_error("Unexpected state %s" % state)
