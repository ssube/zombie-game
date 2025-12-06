@abstract
@icon("res://textures/icons/obj_action.svg")
extends Node
class_name ZN_BaseAction

enum Tristate { NO_CHANGE = -1, SET_FALSE = 0, SET_TRUE = 1 }

@abstract func run(actor: Entity) -> void
