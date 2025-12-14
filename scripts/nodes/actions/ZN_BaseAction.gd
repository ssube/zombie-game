@icon("res://textures/icons/obj_action.svg")
extends Node
class_name ZN_BaseAction

enum Tristate { NO_CHANGE = -1, SET_FALSE = 0, SET_TRUE = 1 }

@export var entity_only: bool = true

var _conditions: Array[ZN_BaseCondition] = []

func _ready() -> void:
	for child in self.get_children():
		if child is ZN_BaseCondition:
			_conditions.append(child)


func run_entity(_actor: Entity, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	pass


func run_physics(_body: PhysicsBody3D, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	pass


func _run(actor: Node, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	if test(actor, area, event):
		if actor is Entity:
			run_entity(actor, area, event)
		elif actor is PhysicsBody3D:
			run_physics(actor, area, event)


## Check condition children before running
func test(actor: Node, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> bool:
	if entity_only:
		if actor is not Entity:
			return false

	for condition in _conditions:
		if not condition.test(actor, area, event):
			return false

	return true
