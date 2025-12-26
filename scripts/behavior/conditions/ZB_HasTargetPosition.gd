extends ZB_Condition
class_name ZB_HasTargetPosition

func test(_actor: Node, _delta: float, behavior: ZC_Behavior) -> bool:
	if behavior.has_value("target_position"):
		return true

	return false
