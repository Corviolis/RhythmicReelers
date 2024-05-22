extends Control

class_name PlayerCard

var player: int
var input: DeviceInput

func init(player_num: int):
	player = player_num
	var device := PlayerManager.get_player_device(player_num)
	input = DeviceInput.new(device)
	
	var device_name = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceName") as Label
	device_name.text = "Device: %d" % device
	var device_icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceIcon") as TextureRect
	if (device == -1):
		var keyboard_icon = load("res://keyboard_icon.tres") as CompressedTexture2D
		device_icon.texture = keyboard_icon
	else:
		var controller_icon = load("res://controller_icon.tres") as CompressedTexture2D
		device_icon.texture = controller_icon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if input.is_action_just_pressed(&"join"):
		PlayerManager.leave(player)