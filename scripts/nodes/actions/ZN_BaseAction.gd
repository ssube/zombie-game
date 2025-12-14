@abstract
@icon("res://textures/icons/obj_action.svg")
extends Node
class_name ZN_BaseAction

enum Tristate { NO_CHANGE = -1, SET_FALSE = 0, SET_TRUE = 1 }

@abstract func run(actor: Entity, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void


func _run(actor: Entity, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	if test(actor, area, event):
		run(actor, area, event)


## Check condition children before running
func test(actor: Entity, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> bool:
	var children := self.get_children()
	for child in children:
		if child is ZN_BaseCondition:
			if not child.test(actor, area, event):
				return false

	return true
