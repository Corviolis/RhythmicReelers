class_name RemapButton
extends Control

var action: String
var event: InputEvent

@onready var assign_button: Button = $Assign


func _ready() -> void:
	set_process_unhandled_input(false)
	if event:
		assign_button.text = ChangeInput.parse_event_button(event.as_text().strip_edges())


func _toggled(is_button_pressed: bool) -> void:
	if is_button_pressed:
		assign_button.text = "[ press ]"
		release_focus()
		(get_node("/root/Control") as Control).mouse_behavior_recursive = (
			Control.MOUSE_BEHAVIOR_DISABLED
		)
		accept_event()
	set_process_unhandled_input(is_button_pressed)


func _unbind() -> void:
	if event:
		InputMap.action_erase_event(action, event)
	assign_button.text = "[ assign ]"


func _unhandled_input(in_event: InputEvent) -> void:
	if not in_event.is_action_type():
		return
	if in_event is InputEventMouseButton:
		(in_event as InputEventMouseButton).double_click = false
	_unbind()
	InputMap.action_add_event(action, in_event)
	assign_button.button_pressed = false
	assign_button.text = ChangeInput.parse_event_button(in_event.as_text().strip_edges())
	(get_node("/root/Control") as Control).mouse_behavior_recursive = (
		Control.MOUSE_BEHAVIOR_INHERITED
	)
	assign_button.grab_focus()
