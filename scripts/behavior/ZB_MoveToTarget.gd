@tool
extends ActionLeaf
class_name ZB_MoveToTarget

@export var force_multiplier: float = 1.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor3d = actor as Node3D

	if blackboard.has_value("target_position"):
		var target_position: Vector3 = blackboard.get_value("target_position")
		if actor3d is RigidBody3D:
			actor3d.apply_force((target_position - actor3d.global_position) * force_multiplier)
			return SUCCESS
		elif actor3d is CharacterBody3D:
			actor3d.velocity = (target_position - actor3d.global_position) * force_multiplier
			actor3d.move_and_slide()

	return FAILURE
