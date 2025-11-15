@tool
extends ActionLeaf
class_name ZB_AttackVisiblePlayer

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	print("Attacking player")
	return SUCCESS
