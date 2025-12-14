extends Area3D
class_name ZN_TriggerArea3D

enum AreaEvent {
	AREA_INTERVAL,
	BODY_ENTER,
	BODY_EXIT,
	BODY_INTERVAL,
}

@export var active: bool = true
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
@export var trigger_on_interval: bool = false

## Retrigger for each colliding body on an interval defined by the body_interval
@export var trigger_on_timer: bool = true


var _actions: Array[ZN_BaseAction] = []
var _area_timer: float = 0.0
var _body_timers: Dictionary[Node, float] = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)


func _process(delta: float) -> void:
	if not active:
		return

	if trigger_on_interval:
		_area_timer += delta
		if _area_timer > area_interval:
			_area_timer = 0.0
			apply_actions(null, self, AreaEvent.AREA_INTERVAL)

	for collider in _body_timers:
		_body_timers[collider] += delta
		if _body_timers[collider] > body_interval:
			_on_body_timer(collider)


func _on_body_entered(body: Node) -> void:
	if not active:
		return

	_body_timers[body] = 0

	if trigger_on_enter:
		apply_actions(body, self, AreaEvent.BODY_ENTER)


func _on_body_exited(body: Node) -> void:
	if not active:
		return

	_body_timers.erase(body)

	if trigger_on_exit:
		apply_actions(body, self, AreaEvent.BODY_EXIT)


func _on_body_timer(body: Node) -> void:
	if not active:
		return

	if trigger_on_timer:
		apply_actions(body, self, AreaEvent.BODY_INTERVAL)


func apply_actions(body: Node, area: ZN_TriggerArea3D, event: AreaEvent) -> void:
	for action in _actions:
		action._run(body, area, event)
