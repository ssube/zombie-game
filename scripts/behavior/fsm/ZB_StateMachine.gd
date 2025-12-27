@icon("res://textures/icons/fsm_machine.svg")
extends Node
class_name ZB_StateMachine

signal state_changed(old_state: ZB_State, new_state: ZB_State)

var states: Dictionary[String, ZB_State] = {}
var transitions: Array[ZB_Transition] = []
var transitions_by_source: Dictionary[ZB_State, Array] = {}
var global_transitions: Array[ZB_Transition] = []
var current_state: ZB_State

@export var active: bool = true
@export var debug: bool = false
@export var default_state: ZB_State = null
@export var entity: Entity = null

@export var states_root: NodePath = "States"
@export var transitions_root: NodePath = "Transitions"


func _ready():
		_cache_states()
		_cache_transitions()
		_build_transition_table()


func _cache_states():
		var states_node = self.get_node(states_root)
		for s in states_node.get_children():
				if s is ZB_State:
						states[s.name] = s


func _cache_transitions():
		var tx_node = self.get_node(transitions_root)
		for t in tx_node.get_children():
				if t is ZB_Transition:
						transitions.append(t)


func _build_transition_table():
		transitions_by_source.clear()
		global_transitions.clear()

		for t in transitions:
				var src = t.source_state
				if src == null:
						global_transitions.append(t)
						continue

				if not transitions_by_source.has(src):
						transitions_by_source[src] = []

				transitions_by_source[src].append(t)


func _check_transitions(delta: float, behavior: ZC_Behavior, force_exit: bool = false) -> void:
		if current_state == null:
				return

		var list: Array[ZB_Transition] = []

		if transitions_by_source.has(current_state):
				list.append_array(transitions_by_source[current_state])

		if global_transitions.size() > 0:
				list.append_array(global_transitions)

		for t in list:
				if t.test(entity, delta, behavior):
						if t.target_state:
								set_state(t.target_state.name)
								return

		if force_exit:
				if default_state:
					if default_state.name == current_state.name:
						printerr("State tried to force exit, but it is the default state")
					else:
						set_state(default_state.name)


func set_state(new_name: String):
		var behavior := entity.get_component(ZC_Behavior) as ZC_Behavior
		var old_state = current_state

		if current_state:
				current_state.exit(entity)

		current_state = states[new_name]
		current_state.enter(entity)

		behavior.current_state = new_name
		state_changed.emit(old_state, current_state)


func tick(delta: float):
	if not active:
		return

	if current_state == null:
		current_state = default_state

	if not current_state:
			return

	var behavior := entity.get_component(ZC_Behavior) as ZC_Behavior
	var result := current_state.tick(entity, delta, behavior)

	if debug:
		var result_name: String = ZB_State.TickResult.keys()[result]
		print("Entity %s ticked state %s with result: %s" % [entity.name, current_state.name, result_name])

	match result:
			ZB_State.TickResult.CONTINUE:
					return

			ZB_State.TickResult.CHECK:
					_check_transitions(delta, behavior)

			ZB_State.TickResult.FORCE_EXIT:
					_check_transitions(delta, behavior, true)
