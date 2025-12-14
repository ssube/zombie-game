extends GPUParticles3D

@export var emit_on_ready: bool = true

func _ready() -> void:
	self.emitting = true
