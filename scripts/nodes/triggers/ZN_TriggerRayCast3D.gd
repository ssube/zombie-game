extends RayCast3D
class_name ZN_TriggerRayCast3D

@export var active: bool = true
@export var parent_entity: Entity

var _actions: Array[ZN_BaseAction] = []
var _last_collider: Node


func _get_body_entity(body: Node) -> Node:
	var entity := CollisionUtils.get_collider_entity(body)
	if entity:
		return entity

	return body


func _ready() -> void:
	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)


func _process(_delta: float) -> void:
	if not self.is_colliding():
		_last_collider = null
		return

	var collider := self.get_collider()
	if collider == _last_collider:
		return

	_last_collider = collider

	var source_entity := _get_body_entity(self)
	for action in _actions:
		action._run(source_entity, Enums.ActionEvent.RAYCAST_COLLISION, collider)
