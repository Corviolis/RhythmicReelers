class_name Bullets

enum Type { BASIC, FLAK }


static func get_scene(bullet: Type) -> PackedScene:
	match bullet:
		Type.BASIC:
			return preload("res://scenes/minigames/shooting/bullets/basic_bullet.tscn")
		Type.FLAK:
			return preload("res://scenes/minigames/shooting/bullets/flak_bullet.tscn")
		_:
			push_error("unknown bullet type")
			return null
