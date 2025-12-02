extends ZB_Condition
class_name ZB_IsTargetNearby

@export var target_range: float = 1.0
@onready var target_range_squared: float = target_range ** 2

func test(actor: Node, _delta: float, blackboard: ZB_Blackboard) -> bool:
	var actor3d = actor as Node3D

	if blackboard.has_value("target_position"):
		var target_position: Vector3 = blackboard.get_value("target_position")
		if target_position.distance_squared_to(actor3d.global_position) < target_range_squared:
			return true

	return false
