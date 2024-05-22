extends Control

class_name PlayerCard

var player: int
var char_index: int
var icon: TextureRect
var input: DeviceInput

func init(player_num: int):
	player = player_num
	char_index = randi() % PlayerManager.get_character_assets().size()
	var device := PlayerManager.get_player_device(player_num)
	input = DeviceInput.new(device)
	
	icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/CharacterSelect/CharacterTexture") as TextureRect
	
	var device_name = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceName") as Label
	device_name.text = "Device: %d" % device
	var device_icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceIcon") as TextureRect
	if (device == -1):
		var keyboard_icon = load("res://keyboard_icon.tres") as CompressedTexture2D
		device_icon.texture = keyboard_icon
	else:
		var controller_icon = load("res://controller_icon.tres") as CompressedTexture2D
		device_icon.texture = controller_icon

func update_char_icon(dir: int):
	char_index = (char_index + dir) % PlayerManager.get_character_assets().size()
	icon.texture = PlayerManager.get_character_assets()[char_index]["idle.png"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if input.is_action_just_pressed(&"join"):
		PlayerManager.leave(player)
		
	if input.is_action_just_pressed(&"ui_left"):
		update_char_icon(-1)
	if input.is_action_just_pressed(&"ui_right"):
		update_char_icon(1)
