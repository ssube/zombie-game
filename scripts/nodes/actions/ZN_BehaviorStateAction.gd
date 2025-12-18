extends ZN_BaseAction
class_name ZN_BehaviorStateAction

@export var state_machine: ZB_StateMachine
@export var switch_state: ZB_State
@export var run_transition: ZB_Transition

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	if run_transition:
		if run_transition.test(state_machine.entity, 0.0, state_machine.blackboard):
			state_machine.set_state(run_transition.target_state.name)

	if switch_state:
		state_machine.current_state = switch_state
