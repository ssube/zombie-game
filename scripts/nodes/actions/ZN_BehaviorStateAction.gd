extends ZN_BaseAction
class_name ZN_BehaviorStateAction

@export var state_machine: ZB_StateMachine

@export_group("Flags")
@export var set_active: Enums.Tristate = Enums.Tristate.UNSET
@export var set_state: ZB_State = null
@export var try_transition: bool = true


func _get_entity(source: Node) -> Entity:
	if source is Entity:
		return source

	return state_machine.entity


func run_node(source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	match set_active:
		Enums.Tristate.FALSE:
			state_machine.active = false
		Enums.Tristate.TRUE:
			state_machine.active = true
		Enums.Tristate.UNSET:
			pass

	# set_state and try_transition are mutually exclusive options
	if set_state:
		state_machine.set_state(set_state.name)
	elif try_transition:
		var entity := _get_entity(source)
		var behavior := entity.get_component(ZC_Behavior) as ZC_Behavior
		state_machine._check_transitions(0.0, behavior)
