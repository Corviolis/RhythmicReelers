extends ProgressBar

@export var health_component: HealthComponent


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(health: int, max_health: int) -> void:
	value = 100 * health / max_health
