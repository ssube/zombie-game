@tool
extends ActionLeaf
class_name ZB_MoveToTarget

@export var force_multiplier: float = 1.0
@export var move_speed: float = 1.0
@export var success_proximity: float = 1.0

@onready var max_move_vector := Vector3(move_speed, move_speed, move_speed)

func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor3d = actor as Node3D

	if not blackboard.has_value("target_position"):
		return FAILURE

	var target_position: Vector3 = blackboard.get_value("target_position")
	var target_proximity: float = actor3d.global_position.distance_to(target_position)
	if target_proximity < success_proximity:
		return SUCCESS

	var target_offset: Vector3 = target_position - actor3d.global_position

	# update from next nav point, if available
	if blackboard.has_value("nav_path"):
		var nav_path: PackedVector3Array = blackboard.get_value("nav_path")
		if len(nav_path) == 0:
			return FAILURE

		var next_point := nav_path[0]
		var nav_proximity: float = actor3d.global_position.distance_to(next_point)
		while nav_proximity < success_proximity and len(nav_path) > 0:
			nav_path.remove_at(0)
			if len(nav_path) > 0:
				blackboard.set_value("nav_path", nav_path)
				next_point = nav_path[0]
				nav_proximity = actor3d.global_position.distance_to(next_point)

		target_offset = next_point - actor3d.global_position

	target_proximity = actor3d.global_position.distance_to(target_position)
	if target_proximity < success_proximity:
		return SUCCESS

	if actor3d is RigidBody3D:
		actor3d.apply_force(target_offset * force_multiplier)
		return RUNNING
	elif actor3d is CharacterBody3D:
		actor3d.velocity = target_offset.max(max_move_vector) * force_multiplier
		# actor3d.move_and_slide()
		# print("TODO: move character by: ", actor3d.velocity)
		return RUNNING
	else:
		printerr("Unknown actor type: ", actor3d.get_class())

	return FAILURE
