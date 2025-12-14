extends Area3D
class_name ZN_TriggerArea3D

@export var active: bool = true
@export var collider_timer: float = 1.0
@export var interval_timer: float = 1.0

@export_group("Triggers")
@export var trigger_on_enter: bool = true
@export var trigger_on_exit: bool = true
@export var trigger_on_interval: bool = true
@export var trigger_on_timer: bool = true
# TODO: trigger when empty


var collider_timers: Dictionary[Node, float] = {}
var interval_delta: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not active:
		return

	if trigger_on_interval:
		interval_delta += delta
		if interval_delta > interval_timer:
			interval_delta = 0.0
			apply_actions(null)

	for collider in collider_timers:
		collider_timers[collider] += delta
		if collider_timers[collider] > collider_timer:
			_on_body_timer(collider)


func _on_body_entered(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	collider_timers[body] = 0

	if trigger_on_enter:
		apply_actions(body)


func _on_body_exited(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	collider_timers.erase(body)

	if trigger_on_exit:
		apply_actions(body)


func _on_body_timer(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	if trigger_on_timer:
		apply_actions(body)


func apply_actions(body: Entity) -> void:
	var children := self.get_children()
	for child in children:
		if child is ZN_BaseAction:
			child.run(body)
