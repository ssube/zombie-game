@icon("res://textures/icons/obj_action.svg")
extends Node
class_name ZN_BaseAction

var _conditions: Array[ZN_BaseCondition] = []

func _ready() -> void:
	for child in self.get_children():
		if child is ZN_BaseCondition:
			_conditions.append(child)


func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	pass


func run_entity(source: Node, event: Enums.ActionEvent, actor: Entity) -> void:
	run_node(source, event, actor)


func run_physics(source: Node, event: Enums.ActionEvent, actor: PhysicsBody3D) -> void:
	run_node(source, event, actor)


func _run(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	if test(source, event, actor):
		if actor is Entity:
			run_entity(source, event, actor)
		elif actor is PhysicsBody3D:
			run_physics(source, event, actor)
		else:
			run_node(source, event, actor)


## Check condition children before running
func test(source: Node, event: Enums.ActionEvent, actor: Node) -> bool:
	for condition in _conditions:
		if not condition.test(source, event, actor):
			return false

	return true
