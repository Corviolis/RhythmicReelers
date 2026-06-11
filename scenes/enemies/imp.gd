extends CharacterBody2D

enum States { NULL, MOVING, ATTACKING, SEARCHING, FLEEING }
var current_state: States = States.NULL

@onready var pathfinding_component: PathfindingComponent = %PathfindingComponent
@onready var attack_component: AttackComponent = %AttackComponent
@onready var boat: Node2D = get_parent().get_parent().get_child(0)

# NOTE: enemies can attack each other? fighting over food, it's like a feeding frenzy
# NOTE: enemies are semi-permenant, but there's large waves
# NOTE: normally, predators don't fight each other over prey
#	- start when neighbour count (or waiting count) reaches a certain point
#	- can just be animation rather than actual friendly fire damage
# NOTE: animals are smart enough to realize when a skirmish isn't worth it (risk/reward)
# NOTE: imps scatter when larger predators arrive
# NOTE: territory is a very important consideration, the only species that lives in a slow
#	predator's territory are those fast enough to evade it


func _ready() -> void:
	change_state(States.MOVING)


func _process(_delta: float) -> void:
	pass


# WARN: change to index before full release
func _get_pathfinding_target() -> Vector2:
	var enemySpots: Array[Marker2D]
	enemySpots.assign(boat.get_node("EnemyTargets").get_children())
	var closest_distance := INF
	var closest: Marker2D
	for spot: Marker2D in enemySpots:
		var distance := global_position.distance_to(spot.global_position)
		if distance < closest_distance:
			closest = spot
			closest_distance = distance
	return closest.global_position


func _on_pathfinding_reached() -> void:
	change_state(States.ATTACKING)


func _on_leave_attack_range() -> void:
	change_state(States.MOVING)


func change_state(state: States) -> void:
	match state:
		States.MOVING:
			pathfinding_component.set_target(_get_pathfinding_target())
		States.ATTACKING:
			print("attack state")
			attack_component.start_attacking()
		_:
			push_error("Unrecognized state %s" % state)
