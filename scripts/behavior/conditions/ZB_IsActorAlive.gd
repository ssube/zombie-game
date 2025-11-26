@tool
extends ConditionLeaf
class_name ZB_IsActorAlive

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor is Entity:
		if actor.has_component(ZC_Health):
			var health = actor.get_component(ZC_Health) as ZC_Health
			if health.current_health > 0:
				return SUCCESS

	return FAILURE
