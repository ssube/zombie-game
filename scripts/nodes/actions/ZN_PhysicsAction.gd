extends ZN_BaseAction
class_name ZN_PhysicsAction

@export var impulse: bool = false
@export var impulse_multiplier: float = 1.0
@export var impulse_offset: Vector3 = Vector3.ZERO


func run(body: Node) -> void:
	if not impulse:
		return

	if body is RigidBody3D:
		var force = body.mass * impulse_multiplier
		body.apply_impulse(Vector3(0, force, 0), self.global_position + impulse_offset)
