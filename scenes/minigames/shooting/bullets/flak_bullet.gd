extends Node2D

@export var attack_component: AttackComponent
@export var particle_component: GPUParticles2D

var fired: bool = false


func _physics_process(_delta: float) -> void:
	if not fired:
		fired = true
		particle_component.emitting = true
		await get_tree().physics_frame
		attack_component.attack()


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
