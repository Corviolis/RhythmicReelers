class_name PlayerCard
extends Control

var player: int
var char_index: int
var icon: TextureRect
var input: DeviceInput
var device: int

func init(player_num: int):
	player = player_num
	device = PlayerManager.get_player_device(player_num)
	input = DeviceInput.new(device)
	icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/CharacterSelect/CharacterTexture") as TextureRect
	
	_set_device_icon()

	set_char_icon(PlayerManager.get_player_data(player, "character_index"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_multiplayer_authority():
		if input.is_action_just_pressed(&"join"):
			PlayerManager.leave.rpc(player)
		if input.is_action_just_pressed(&"move_left"):
			decrease_char_icon()
		if input.is_action_just_pressed(&"move_right"):
			increase_char_icon()

@rpc("any_peer", "call_local", "reliable")
func set_char_icon(dir: int):
	char_index = (dir) % PlayerManager.get_character_asset_count()
	icon.texture = PlayerManager.get_character_assets(char_index)["idle.png"]
	PlayerManager.set_player_data(player, "character_index", char_index)

# these two functions exist solely for the sake of button signals
func increase_char_icon():
	set_char_icon.rpc(char_index+1)
func decrease_char_icon():
	set_char_icon.rpc(char_index-1)

func _set_device_icon():
	var device_name = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceName") as Label
	device_name.text = "authority: %d" % get_multiplayer_authority()
	var device_icon = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceIcon") as TextureRect
	if (device == -1 or device == -2):
		var keyboard_icon = load("res://art/ui/keyboard_icon.tres") as CompressedTexture2D
		device_icon.texture = keyboard_icon
	else:
		var controller_icon = load("res://art/ui/controller_icon.tres") as CompressedTexture2D
		device_icon.texture = controller_icon
