@tool
extends ActionLeaf
class_name ZB_TargetVisiblePlayer

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.has_value("target_player"):
		var player3d = blackboard.get_value("target_player") as Node3D
		blackboard.set_value("target_position", player3d.global_position)
		return SUCCESS

	return FAILURE

