extends ZB_Condition
class_name ZB_IsActorAlive

func test(actor: Entity, _delta: float, _blackboard: ZB_Blackboard) -> bool:
	if actor.has_component(ZC_Health):
		var health = actor.get_component(ZC_Health) as ZC_Health
		if health.current_health > 0:
			return true

	return false
