class_name ChangeInput
extends HBoxContainer

var events: Array[InputEvent] = []
var buttons: int = 3


func setup(action: StringName) -> void:
	($Label as Label).text = action.substr(0, 15)
	events = InputMap.action_get_events(action)
	for i in buttons:
		var remap_button: RemapButton = get_child(i + 1) as RemapButton
		remap_button.action = action
		if events.size() > i:
			remap_button.event = events[i]


static func parse_event_button(text_in: String) -> String:
	if text_in.ends_with("- Physical"):
		return text_in.trim_suffix("- Physical")
	elif text_in.contains("Joypad Button"):
		return text_in.get_slice(",", 0).get_slice("(", 1).trim_suffix(")")
	elif text_in.contains("Joypad Motion"):
		if text_in.contains("Axis 4"):
			return "Left Trigger"
		if text_in.contains("Axis 5"):
			return "Right Trigger"
		return text_in.get_slice(",", 0).get_slice("(", 1).trim_suffix(")")
	elif text_in == "Left Mouse Button":
		return "LMB"
	elif text_in == "Right Mouse Button":
		return "RMB"
	elif text_in.contains("Thumb Button"):
		return "Thumb " + text_in.trim_prefix("Mouse Thumb Button ")
	else:
		return text_in
