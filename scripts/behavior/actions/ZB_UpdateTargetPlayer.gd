@tool
extends ActionLeaf
class_name ZB_UpdateTargetPlayer

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if not blackboard.has_value("visible_player"):
		return FAILURE

	var player: Node3D = blackboard.get_value("visible_player")
	blackboard.set_value("target_player", player)
	return SUCCESS
