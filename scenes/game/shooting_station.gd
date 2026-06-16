class_name ShootingStation
extends StationInteractable

signal loaded_bullet(bullets: Array[Bullets.Type])

var loaded_bullets: Array[Bullets.Type]
var max_bullets := INF


func load_bullet(type: Bullets.Type) -> void:
	if loaded_bullets.size() >= max_bullets:
		return
	loaded_bullets.append(type)
	loaded_bullet.emit(loaded_bullets)


func shoot_bullet() -> PackedScene:
	if loaded_bullets.size() == 0:
		return null
	var bullet: Bullets.Type = loaded_bullets.pop_front()
	loaded_bullet.emit(loaded_bullets)
	return Bullets.get_scene(bullet)
