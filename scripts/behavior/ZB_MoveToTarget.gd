@tool
extends ActionLeaf
class_name ZB_MoveToTarget

@export var force_multiplier: float = 1.0
@export var move_speed: float = 1.0
@onready var max_move_vector := Vector3(move_speed, move_speed, move_speed)

func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor3d = actor as Node3D

	if blackboard.has_value("target_position"):
		var target_position: Vector3 = blackboard.get_value("target_position")
		var target_offset = target_position - actor3d.global_position

		if actor3d is RigidBody3D:
			actor3d.apply_force((target_position - actor3d.global_position) * force_multiplier)
			return SUCCESS
		elif actor3d is CharacterBody3D:
			actor3d.velocity = target_offset.max(max_move_vector) * force_multiplier
			# actor3d.move_and_slide()
			# print("TODO: move character by: ", actor3d.velocity)

	return FAILURE
