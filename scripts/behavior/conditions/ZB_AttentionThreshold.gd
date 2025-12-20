extends ZB_Condition
class_name ZB_AttentionThreshold

@export var threshold: float = 0.5
@export var allow_above: bool = true
@export var allow_below: bool = false

func test(entity: Entity, _delta: float, _blackboard: ZB_Blackboard) -> bool:
	var attention := entity.get_component(ZC_Attention) as ZC_Attention
	if attention == null:
		return false

	if allow_above and attention.score >= threshold:
		return true

	if allow_below and attention.score <= threshold:
		return true

	return false