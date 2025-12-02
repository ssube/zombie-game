extends ZB_Condition
class_name ZB_HasTargetPosition

func test(_actor: Node, _delta: float, blackboard: ZB_Blackboard) -> bool:
	if blackboard.has_value("target_position"):
		return true

	return false
