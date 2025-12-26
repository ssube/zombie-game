extends ZB_Condition
class_name ZB_Condition_Throttle

@export var interval: float = 0.0

var timer = 0.0

func test(_entity: Entity, delta: float, _behavior: ZC_Behavior) -> bool:
	timer += delta
	if timer > interval:
		timer = 0.0
		return true

	return false
