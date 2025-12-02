@icon("res://textures/icons/fsm_transition.svg")
extends Node
class_name ZB_Transition

@export var any_source: bool = false
@export var source_state: ZB_State = null
@export var target_state: ZB_State = null

var conditions: Array[ZB_Condition] = []

func _ready():
		assert(target_state != null, "Target state must be defined")
		if not any_source:
			assert(source_state != null, "Source state must be defined or the any source flag must be set")

		# Collect all direct child condition nodes
		for c in get_children():
				if c is ZB_Condition:
						conditions.append(c)

func test(entity: Entity, delta: float, blackboard: ZB_Blackboard) -> bool:
		for c in conditions:
				if not c.test(entity, delta, blackboard):
						return false

		return true
