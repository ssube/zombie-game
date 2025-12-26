extends ZB_Condition
class_name ZB_Condition_All

var children: Array = []

func _ready():
		for c in get_children():
				if c is ZB_Condition:
						children.append(c)

func test(entity: Entity, delta: float, behavior: ZC_Behavior) -> bool:
		for c in children:
				if not c.test(entity, delta, behavior):
						return false
		return true
