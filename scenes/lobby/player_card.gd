class_name PlayerCard
extends Control

var player: int
var char_index: int
var input: DeviceInput
var device: int
var color_replace_shader := preload("res://art/shaders/color_replace.gdshader") as Shader

@onready
var sprite: TextureRect = get_node("PanelContainer/MarginContainer/VBoxContainer/CharacterTexture")
@onready var name_tag: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/PlayerName")


func init(player_num: int):
	player = player_num
	device = PlayerManager.get_player_device(player_num)
	input = DeviceInput.new(device)
	name_tag.text = ("Player %d" % (player + 1))
	_show_player_authority()
	# _set_device_icon()
	set_char_icon(PlayerManager.get_player_data(player, "character_index"))
	if !is_multiplayer_authority():
		$PanelContainer/MarginContainer/VBoxContainer/CharacterSelect/SwitchLeft.visible = false
		$PanelContainer/MarginContainer/VBoxContainer/CharacterSelect/SwitchRight.visible = false
		$PanelContainer/MarginContainer/VBoxContainer/ReadyUp.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_multiplayer_authority():
		if input.is_action_just_pressed(&"join"):
			PlayerManager.leave.rpc(player)
		if input.is_action_just_pressed(&"move_left"):
			decrease_char_icon()
		if input.is_action_just_pressed(&"move_right"):
			increase_char_icon()


@rpc("authority", "call_local", "reliable")
func set_char_icon(dir: int):
	char_index = (dir) % PlayerManager.get_character_asset_count()
	sprite.texture = PlayerManager.get_character_assets(char_index)["idle.png"]
	sprite.material = PlayerManager.get_character_assets(char_index)["material.tres"]
	PlayerManager.set_player_data(player, "character_index", char_index)


# these two functions exist solely for the sake of button signals
func increase_char_icon():
	set_char_icon.rpc(char_index + 1)


func decrease_char_icon():
	set_char_icon.rpc(char_index - 1)


func _show_player_authority():
	var device_name = get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceName") as Label
	device_name.text = "authority:\n%d" % get_multiplayer_authority()


func _set_device_icon():
	var device_icon = (
		get_node(^"PanelContainer/MarginContainer/VBoxContainer/DeviceIcon") as TextureRect
	)
	if device == -1 or device == -2:
		var keyboard_icon = load("res://art/ui/keyboard_icon.tres") as CompressedTexture2D
		device_icon.texture = keyboard_icon
	else:
		var controller_icon = load("res://art/ui/controller_icon.tres") as CompressedTexture2D
		device_icon.texture = controller_icon
