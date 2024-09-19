class_name Player
extends CharacterBody2D

const SPEED = 100
var input: DeviceInput
var player_id: int
var color: Color
var nearby_interactables: Array[StationInteractable]

@onready var window_manager := get_node("/root/Game/WindowManager") as WindowManager
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $Area2D


func _ready():
	if is_multiplayer_authority():
		print(self.name, " ", multiplayer.get_unique_id())
	color = sprite.material.get_shader_parameter("foreground_color")
	interaction_area.area_entered.connect(add_interactable)
	interaction_area.area_exited.connect(remove_interactable)


func _physics_process(_delta):
	if !input:
		return

	var direction := Vector2.ZERO
	if is_multiplayer_authority():
		direction = input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 100)

	move_and_slide()


func _input(event):
	if !is_multiplayer_authority():
		return
	elif event.is_action_pressed("interact"):
		if not nearby_interactables.is_empty():
			nearby_interactables.back().interact(self)


func set_device(device: int):
	input = DeviceInput.new(device)


func add_interactable(area2d: Area2D) -> void:
	if not nearby_interactables.is_empty():
		nearby_interactables.back().remove_nearby_player(self)
	var interactable: StationInteractable = area2d.get_parent()
	nearby_interactables.append(interactable)
	interactable.add_nearby_player(self)


func remove_interactable(area2d: Area2D) -> void:
	var current_interact_target = nearby_interactables.back()
	var interactable: StationInteractable = area2d.get_parent()
	nearby_interactables.erase(interactable)
	if interactable == current_interact_target:
		interactable.remove_nearby_player(self)
		if not nearby_interactables.is_empty():
			nearby_interactables.back().add_nearby_player(self)
