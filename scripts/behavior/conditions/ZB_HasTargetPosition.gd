@tool
extends ConditionLeaf
class_name ZB_HasTargetPosition

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.has_value("target_position"):
		return SUCCESS

	return FAILURE
