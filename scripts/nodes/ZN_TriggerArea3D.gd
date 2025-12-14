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


var area_timer: float = 0.0
var body_timers: Dictionary[Node, float] = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not active:
		return

	if trigger_on_interval:
		area_timer += delta
		if area_timer > area_interval:
			area_timer = 0.0
			apply_actions(null, self, AreaEvent.AREA_INTERVAL)

	for collider in body_timers:
		body_timers[collider] += delta
		if body_timers[collider] > body_interval:
			_on_body_timer(collider)


func _on_body_entered(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	body_timers[body] = 0

	if trigger_on_enter:
		apply_actions(body, self, AreaEvent.BODY_ENTER)


func _on_body_exited(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	body_timers.erase(body)

	if trigger_on_exit:
		apply_actions(body, self, AreaEvent.BODY_EXIT)


func _on_body_timer(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	if trigger_on_timer:
		apply_actions(body, self, AreaEvent.BODY_INTERVAL)


func apply_actions(body: Entity, area: ZN_TriggerArea3D, event: AreaEvent) -> void:
	var children := self.get_children()
	for child in children:
		if child is ZN_BaseAction:
			child._run(body, area, event)
