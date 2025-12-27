extends ZB_State
class_name ZB_State_Halt

func tick(entity: Entity, _delta: float, behavior: ZC_Behavior) -> int:
	var state_machine := entity.get_node(behavior.state_machine) as ZB_StateMachine
	state_machine.active = false
	return TickResult.FORCE_EXIT
