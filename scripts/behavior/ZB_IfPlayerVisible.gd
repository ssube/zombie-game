@tool
extends ConditionLeaf
class_name ZB_IfPlayerVisible

@export var vision_cone: Area3D = null

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.has_value("target_player"):
		return SUCCESS

	return FAILURE
