extends System
class_name ZS_BehaviorSystem


func query() -> QueryBuilder:
	return q.with_all([ZC_Behavior])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var behavior := entity.get_component(ZC_Behavior) as ZC_Behavior
		if not behavior.active:
			continue

		var state_machine := entity.get_node(behavior.state_machine) as ZB_StateMachine
		state_machine.tick(delta)
