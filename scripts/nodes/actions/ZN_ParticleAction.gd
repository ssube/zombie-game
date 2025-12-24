extends ZN_BaseAction
class_name ZN_ParticleAction

@export var particle_system: GPUParticles3D

@export var emitting: Enums.Tristate = Enums.Tristate.UNSET
#@export var emit_once: bool = false
@export var restart: bool = false

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	match emitting:
		Enums.Tristate.FALSE:
			particle_system.emitting = false
		Enums.Tristate.TRUE:
			particle_system.emitting = true
		Enums.Tristate.UNSET:
			pass

	if restart:
		particle_system.restart()
