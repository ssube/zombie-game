@tool
extends ConditionLeaf
class_name ZB_IfPlayerNearby

@export var detection_range: float = 10.0
@onready var detection_range_squared: float = detection_range ** 2

func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor3d = actor as Node3D

	if ECS.world == null:
		return FAILURE

	var players: Array = QueryBuilder.new(ECS.world).with_all([ZC_Player]).execute()

	for player in players:
		var player3d = player as Node3D
		if player3d.global_position.distance_squared_to(actor3d.global_position) < detection_range_squared:
			blackboard.set_value("target_player", player)
			return SUCCESS

	return FAILURE
