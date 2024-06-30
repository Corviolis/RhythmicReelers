extends Node

@onready var current_scene := get_tree().current_scene

func equal_approx(a: float, b: float, accuracy) -> bool:
	return abs(a - b) < accuracy

@rpc("call_local", "reliable")
func goto_scene(path: String):
	call_deferred(&"_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	current_scene.free()
	var new_scene := ResourceLoader.load(path) as PackedScene
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
