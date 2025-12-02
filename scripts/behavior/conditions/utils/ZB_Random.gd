extends ZB_Condition
class_name ZB_Condition_Random

@export_range(0.0, 1.0) var probability := 0.5

func test(_entity: Entity, _delta: float, _blackboard: ZB_Blackboard) -> bool:
	return randf() <= probability
