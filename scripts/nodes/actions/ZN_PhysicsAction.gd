extends ZN_BaseAction
class_name ZN_PhysicsAction

enum PhysicsOrigin {
	AREA,
	BODY,
}

@export var impulse: bool = false
@export var impulse_multiplier: float = 1.0
@export var impulse_offset: Vector3 = Vector3.ZERO
@export var impulse_origin: PhysicsOrigin = PhysicsOrigin.AREA


func _get_position(body: Node3D, area: ZN_TriggerArea3D) -> Vector3:
	match impulse_origin:
		PhysicsOrigin.AREA:
			return area.global_position
		PhysicsOrigin.BODY:
			return body.global_position

	return Vector3.ZERO


func run(body: Node, area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	if not impulse:
		return

	var origin := _get_position(body, area)

	if body is RigidBody3D:
		var force = body.mass * impulse_multiplier
		body.apply_impulse(Vector3(0, force, 0), origin + impulse_offset)
