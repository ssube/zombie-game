extends Timer
class_name ZN_TriggerTimer


@export var start_on_ready: bool = true
@export var repeat: bool = false
@export var parent_entity: Entity


var _actions: Array[ZN_BaseAction] = []


func _get_body_entity(body: Node) -> Node:
	var entity := CollisionUtils.get_collider_entity(body)
	if entity:
		return entity

	return body


func _ready() -> void:
	self.one_shot = not repeat
	self.timeout.connect(on_timeout)

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)

	if start_on_ready:
		self.start()


func on_timeout() -> void:
	apply_actions(self, Enums.ActionEvent.TIMER_TIMEOUT, null)


func apply_actions(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	var source_entity := _get_body_entity(source)
	for action in _actions:
		action._run(source_entity, event, actor)
