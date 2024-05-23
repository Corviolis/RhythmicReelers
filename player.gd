extends CharacterBody2D

class_name Player

const SPEED = 100

var input : DeviceInput

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

func set_device(device: int):
	input = DeviceInput.new(device)
