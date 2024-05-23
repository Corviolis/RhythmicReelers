extends Control

class_name PlayerCard

var player: int
var char_index: int
var icon: TextureRect
var input: DeviceInput

var device

func init(player_num: int):
	player = player_num
	device = PlayerManager.get_player_device(player_num)
	char_index = randi() % PlayerManager.get_character_asset_count()
	input = DeviceInput.new(device)
	
	icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/CharacterSelect/CharacterTexture") as TextureRect
	
	var device_name = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceName") as Label
	device_name.text = "Device: %d" % device
	var device_icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceIcon") as TextureRect
	if (device == -1 or device == -2):
		var keyboard_icon = load("res://keyboard_icon.tres") as CompressedTexture2D
		device_icon.texture = keyboard_icon
	else:
		var controller_icon = load("res://controller_icon.tres") as CompressedTexture2D
		device_icon.texture = controller_icon

# BUG: sometimes it takes two clicks to change this?
# TODO: make card show up with the right icon when new players connect to an existing server
@rpc("any_peer", "call_local", "reliable")
func set_char_icon(dir: int):
	char_index = (dir) % PlayerManager.get_character_asset_count()
	icon.texture = PlayerManager.get_character_assets(char_index)["idle.png"]

# these two functions exist solely for the sake of button signals
func increase_char_icon():
	set_char_icon.rpc(char_index+1)
func decrease_char_icon():
	set_char_icon.rpc(char_index-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_multiplayer_authority():
		if input.is_action_just_pressed(&"join"):
			PlayerManager.leave.rpc(player)
		if input.is_action_just_pressed(&"move_left"):
			decrease_char_icon()
		if input.is_action_just_pressed(&"move_right"):
			increase_char_icon()
