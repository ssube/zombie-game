extends Area3D
class_name ZN_TriggerArea3D

@export var active: bool = true
@export var use_body_entity: bool = true
@export var track_colliders: bool = false
@export var parent_entity: Entity

@export_group("Intervals")
@export var area_interval: float = 1.0
@export var body_interval: float = 1.0

@export_group("Triggers")
## Trigger when all bodies have left and the area is empty
@export var trigger_on_empty: bool = false

## Trigger when a body enters
@export var trigger_on_enter: bool = true

## Trigger when a body leaves
@export var trigger_on_exit: bool = false

## Retrigger for the area itself on an interval defined by the area_interval
@export var trigger_on_area_interval: bool = false

## Retrigger for each colliding body on an interval defined by the body_interval
@export var trigger_on_body_interval: bool = true


var _actions: Array[ZN_BaseAction] = []
var _colliders: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)

	if trigger_on_area_interval and area_interval > 0.0:
		_add_area_timer()


func _add_area_timer(start: bool = true) -> void:
	var timer := ZN_AreaTimer.new()
	timer.area = self
	timer.wait_time = area_interval
	timer.one_shot = false
	timer.timeout.connect(_on_area_timer.bind(self))
	self.add_child(timer)

	if start:
		timer.start()


func _add_body_timer(body: Node, start: bool = true) -> void:
	var timer := ZN_AreaTimer.new()
	timer.area = self
	timer.wait_time = body_interval
	timer.one_shot = false
	timer.timeout.connect(_on_body_timer.bind(body))
	body.add_child(timer)

	if start:
		timer.start()


func _remove_body_timer(body: Node) -> void:
	for child in body.get_children():
		if child is ZN_AreaTimer and child.area == self:
			# needs to be deferred because other add/removal may already be running
			body.remove_child.call_deferred(child)


func _on_area_timer(area: ZN_TriggerArea3D) -> void:
	if not active:
		return

	apply_actions(area, Enums.ActionEvent.AREA_INTERVAL, null)


func _on_body_entered(body: Node) -> void:
	if not active:
		return

	if track_colliders:
		_colliders.append(body)

	if trigger_on_body_interval and body_interval > 0.0:
		_add_body_timer(body)

	if trigger_on_enter:
		apply_actions(self, Enums.ActionEvent.BODY_ENTER, body)


func _on_body_exited(body: Node) -> void:
	if not active:
		return

	if track_colliders:
		_colliders.erase(body)

	_remove_body_timer(body)

	if trigger_on_exit:
		apply_actions(self, Enums.ActionEvent.BODY_EXIT, body)

	if trigger_on_empty and _colliders.size() == 0:
		apply_actions(self, Enums.ActionEvent.AREA_EMPTY, null)


func _on_body_timer(body: Node) -> void:
	if not active:
		return

	if trigger_on_body_interval:
		apply_actions(self, Enums.ActionEvent.BODY_INTERVAL, body)


func _get_body_entity(body: Node) -> Node:
	var entity := CollisionUtils.get_collider_entity(body)
	if entity:
		return entity

	return body


func apply_actions(source: Node, event: Enums.ActionEvent, body: Node) -> void:
	var actor := body
	if use_body_entity:
		actor = _get_body_entity(body)

	var source_entity := _get_body_entity(source)

	# assert(actor != null, "Actor should not be null for trigger area!")
	for action in _actions:
		action._run(source_entity, event, actor)
