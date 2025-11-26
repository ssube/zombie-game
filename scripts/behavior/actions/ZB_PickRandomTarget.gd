@tool
extends ActionLeaf
class_name ZB_PickRandomTarget

@export var target_range: float = 5.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor3d = actor as Node3D
	var randomX = randf_range(actor3d.global_position.x - target_range, actor3d.global_position.x + target_range)
	# var randomY = randf_range(actor3d.global_position.y - target_range, actor3d.global_position.y + target_range)
	var randomZ = randf_range(actor3d.global_position.z - target_range, actor3d.global_position.z + target_range)
	var randomTarget = Vector3(randomX, actor3d.global_position.y, randomZ)
	blackboard.set_value("target_position", randomTarget)

	return SUCCESS
