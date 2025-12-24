extends ZN_BaseCondition
class_name ZN_BehaviorStateCondition

@export var state_machine: ZB_StateMachine
@export var allowed_states: Array[ZB_State] = []

func test(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> bool:
	if state_machine.current_state in allowed_states:
		return true

	return false

