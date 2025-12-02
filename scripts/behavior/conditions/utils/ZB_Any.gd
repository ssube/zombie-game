extends ZB_Condition
class_name ZB_Condition_Any

var children: Array = []

func _ready():
		for c in get_children():
				if c is ZB_Condition:
						children.append(c)

func test(entity: Entity, delta: float, blackboard: ZB_Blackboard) -> bool:
		for c in children:
				if c.test(entity, delta, blackboard):
						return true
		return false
