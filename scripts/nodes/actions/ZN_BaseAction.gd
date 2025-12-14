@abstract
@icon("res://textures/icons/obj_action.svg")
extends Node
class_name ZN_BaseAction

enum Tristate { NO_CHANGE = -1, SET_FALSE = 0, SET_TRUE = 1 }

@abstract func run(actor: Entity, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void

var _conditions: Array[ZN_BaseCondition] = []

func _ready() -> void:
	for child in self.get_children():
		if child is ZN_BaseCondition:
			_conditions.append(child)


func _run(actor: Entity, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	if test(actor, area, event):
		run(actor, area, event)


## Check condition children before running
func test(actor: Entity, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> bool:
	for condition in _conditions:
		if not condition.test(actor, area, event):
			return false

	return true
