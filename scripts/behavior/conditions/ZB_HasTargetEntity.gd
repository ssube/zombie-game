extends ZB_Condition
class_name ZB_HasTargetEntity

func test(entity: Entity, _delta: float, _blackboard: ZB_Blackboard) -> bool:
	var attention := entity.get_component(ZC_Attention) as ZC_Attention
	if attention == null:
		return false

	return attention.target_entity != ""
