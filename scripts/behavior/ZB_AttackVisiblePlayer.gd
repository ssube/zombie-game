@tool
extends ActionLeaf
class_name ZB_AttackVisiblePlayer

@export var attack_cooldown: float = 2.0
var attack_delta: float = 0.0

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if attack_delta < attack_cooldown:
		attack_delta += get_physics_process_delta_time()
		return RUNNING

	attack_delta = 0.0
	print("Attacking player")
	return SUCCESS
