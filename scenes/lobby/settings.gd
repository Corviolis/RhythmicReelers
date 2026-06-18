extends Control

@export var lobby: Control

var remap_action_scene: PackedScene = preload("res://scenes/lobby/change_input.tscn")

@onready var remap_actions: Control = %RemapActions


func toggle_open() -> void:
	visible = !visible
	mouse_filter = Control.MOUSE_FILTER_STOP if visible else Control.MOUSE_FILTER_IGNORE
	lobby.process_mode = Node.PROCESS_MODE_DISABLED if visible else Node.PROCESS_MODE_INHERIT


func _ready() -> void:
	for action: StringName in InputMap.get_actions():
		if action.begins_with("ui"):
			continue
		var change_input := remap_action_scene.instantiate() as ChangeInput
		change_input.setup(action)
		remap_actions.add_child(change_input)

# func _input(event: InputEvent) -> void:
# 	if event.is_action("exit") and visible:
# 		toggle_open()
