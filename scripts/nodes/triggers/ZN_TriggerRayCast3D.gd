extends RayCast3D
class_name ZN_TriggerRayCast3D

@export var active: bool = true

var _actions: Array[ZN_BaseAction] = []
var _last_collider: Node


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

	for action in _actions:
		action._run(self, Enums.ActionEvent.RAYCAST_COLLISION, collider)
