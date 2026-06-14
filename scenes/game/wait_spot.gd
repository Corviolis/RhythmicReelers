class_name WaitSpot
extends Marker2D

@export var max_capacity := 4
@export var neighbors: Array[WaitSpot]

var occupants: int
var open_spaces: int:
	get:
		return max_capacity - occupants
var is_full: bool:
	get:
		return occupants >= max_capacity

@onready var attack_slots: Array[AttackSpot]


func _ready() -> void:
	attack_slots.assign(get_children())
	attack_slots.shuffle()


func get_available_slot() -> AttackSpot:
	for slot: AttackSpot in attack_slots:
		if slot.is_available:
			return slot
	return null


func get_most_available_neighbour() -> WaitSpot:
	return neighbors.reduce(
		func(min_occ: WaitSpot, wait_spot: WaitSpot) -> WaitSpot:
			return wait_spot if wait_spot.open_spaces > min_occ.open_spaces else min_occ
	)


func add_occupant() -> void:
	occupants += 1


func remove_occupant() -> void:
	occupants -= 1
