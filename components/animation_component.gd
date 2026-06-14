extends AnimationTree

@onready var state: AnimationNodeStateMachinePlayback = self["parameters/playback"]


func _on_die() -> void:
	state.travel("die")
