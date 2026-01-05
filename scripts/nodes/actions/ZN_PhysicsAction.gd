@tool
extends ZN_BaseAction
class_name ZN_PhysicsAction

enum PhysicsOrigin {
	SOURCE,
	BODY,
}

@export var impulse: bool = false
@export var impulse_multiplier: float = 1.0
@export var impulse_offset: Vector3 = Vector3.ZERO
@export var impulse_origin: PhysicsOrigin = PhysicsOrigin.SOURCE


func _get_position(source: Node3D, body: Node3D) -> Vector3:
	match impulse_origin:
		PhysicsOrigin.BODY:
			return body.global_position
		PhysicsOrigin.SOURCE:
			return source.global_position

	return Vector3.ZERO


func run_entity(source: Node, event: Enums.ActionEvent, actor: Entity) -> void:
	var body := actor as Node
	if body is PhysicsBody3D:
		run_physics(source, event, body)


func run_physics(source: Node, _event: Enums.ActionEvent, body: PhysicsBody3D) -> void:
	if not impulse:
		return

	var origin := _get_position(source, body)

	if body is RigidBody3D:
		var force = body.mass * impulse_multiplier
		body.apply_impulse(Vector3(0, force, 0), origin + impulse_offset)
