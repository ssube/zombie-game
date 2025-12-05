extends Area3D
class_name ZN_TriggerArea3D

@export var active: bool = true
@export var interval: float = 1.0
@export var components: Array[Component] = []
@export var relationships: Array[Relationship] = []

@export_group("Triggers")
@export var trigger_on_enter: bool = true
@export var trigger_on_exit: bool = true
@export var trigger_on_timer: bool = true

@export_group("Physics")
@export var impulse: bool = false
@export var impulse_multiplier: float = 1.0

var collider_timers: Dictionary[Node, float] = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not active:
		return

	for collider in collider_timers:
		collider_timers[collider] += delta
		if collider_timers[collider] > interval:
			_on_body_timer(collider)


func _on_body_entered(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	collider_timers[body] = 0

	if trigger_on_enter:
		apply_components(body)
		apply_impulse(body)


func _on_body_exited(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	collider_timers.erase(body)

	if trigger_on_exit:
		apply_components(body)
		apply_impulse(body)


func _on_body_timer(body: Node) -> void:
	if not active:
		return

	if not body is Entity:
		return

	if trigger_on_timer:
		apply_components(body)
		apply_impulse(body)


func apply_components(body: Entity) -> void:
	var new_components := components.duplicate_deep()
	if new_components.size() > 0:
		body.add_components(new_components)

	var new_relationships := relationships.duplicate_deep()
	if new_relationships.size() > 0:
		body.add_relationships(new_relationships)


func apply_impulse(body: Node) -> void:
	if not impulse:
		return

	if body is RigidBody3D:
		var force = body.mass * impulse_multiplier
		body.apply_impulse(Vector3(0, force, 0), self.global_position)
