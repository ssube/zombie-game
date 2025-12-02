extends ZB_Condition
class_name ZB_Condition_Not

var child: ZB_Condition

func _ready():
		assert(get_child_count() == 1, "Not conditions should only have one child.")
		child = get_child(0)

func test(entity: Entity, delta: float, blackboard: ZB_Blackboard) -> bool:
		if child:
				return not child.test(entity, delta, blackboard)

		return false
