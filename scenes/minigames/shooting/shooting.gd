extends Minigame

var using_mouse: bool = false
var crosshair_speed: float = 200


func _ready():
	var device = PlayerManager.get_player_device(player_id)
	input = DeviceInput.new(device)


func _process(delta: float):
	_handle_input(delta)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		using_mouse = true


func _handle_input(delta: float):
	if !is_multiplayer_authority():
		return
	if input.is_action_just_pressed("exit"):
		_exit_minigame()
	if input.is_action_just_pressed("beat"):
		_beat()

	var movement_vector := input.get_vector("move_left", "move_right", "move_up", "move_down")
	if movement_vector != Vector2.ZERO:
		using_mouse = false
	if using_mouse and input.is_keyboard():
		position = get_global_mouse_position()
	position += movement_vector * delta * crosshair_speed
	position.x = maxf(position.x, -get_viewport().get_visible_rect().size.x / (2 * 4))
	position.y = maxf(position.y, -get_viewport().get_visible_rect().size.y / (2 * 4))
	position.x = minf(position.x, get_viewport().get_visible_rect().size.x / (2 * 4))
	position.y = minf(position.y, get_viewport().get_visible_rect().size.y / (2 * 4))
