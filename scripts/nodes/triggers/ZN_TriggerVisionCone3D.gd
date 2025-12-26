@tool
extends VisionCone3D
class_name ZN_TriggerVisionCone3D

@export var active: bool = true
@export var use_body_entity: bool = true
@export var track_colliders: bool = false
@export var parent_entity: Entity

@export_group("Triggers")
@export_subgroup("Area")
@export var trigger_on_enter: bool = false
@export var trigger_on_exit: bool = false
@export var trigger_on_empty: bool = false

@export_subgroup("Vision")
@export var trigger_on_sight: bool = true
@export var trigger_on_lost: bool = true


var _actions: Array[ZN_BaseAction] = []


func _get_prober_for_shape(shape: CollisionShape3D, body: CollisionObject3D) -> VisionTestProber:
	for prober: VisionTestProber in _body_probe_data.get(body, []):
		if prober.collision_shape == shape:
			return prober

	return null


func _on_body_shape_exited(
	_body_rid: RID,
	body: Node3D,
	body_shape_index: int,
	_local_shape_index: int,
) -> void:
	if !body:
		return

	if body not in _body_probe_data:
		return

	var shape := _get_collision_shape_node_in_body(body, body_shape_index)
	var prober := _get_prober_for_shape(shape, body)
	var body_probers : Array[VisionTestProber]= _body_probe_data[body]
	body_probers.erase(prober)
	if body_probers.is_empty():
		_body_probe_data.erase(body)


func _ready() -> void:
	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)

	if trigger_on_enter:
		self.body_entered.connect(on_body_entered)

	if trigger_on_exit:
		self.body_exited.connect(on_body_exited)

	if trigger_on_empty:
		pass

	if trigger_on_sight:
		self.body_sighted.connect(on_body_sighted)

	if trigger_on_lost:
		self.body_hidden.connect(on_body_hidden)


func on_body_entered(body: Node) -> void:
	if not active:
		return

	apply_actions(self, Enums.ActionEvent.BODY_ENTER, body)


func on_body_exited(body: Node) -> void:
	if not active:
		return

	apply_actions(self, Enums.ActionEvent.BODY_EXIT, body)


func on_body_sighted(body: Node) -> void:
	if not active:
		return

	apply_actions(self, Enums.ActionEvent.VISION_SEEN, body)


func on_body_hidden(body: Node) -> void:
	if not active:
		return

	apply_actions(self, Enums.ActionEvent.VISION_HIDDEN, body)


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
	for action in _actions:
		action._run(source_entity, event, actor)
