@icon("res://textures/icons/fsm_state.svg")
extends Node
class_name ZB_State


@export var debug_color: Color = Color(1, 1, 1, 1)


enum TickResult { CONTINUE, CHECK, FORCE_EXIT }

## Called when entering the state
func enter(_entity: Entity): pass

## Called when leaving the state
func exit(_entity: Entity): pass

## Called every frame while the state is active
func tick(_entity: Entity, _delta: float, _behavior: ZC_Behavior) -> int:
	return TickResult.CHECK # CONTINUE
