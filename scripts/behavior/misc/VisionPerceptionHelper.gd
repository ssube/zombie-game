@icon("res://textures/icons/fsm_trigger.svg")
extends Node
class_name ZB_VisionPerceptionHelper


@export var vision_area: VisionCone3D


# Entity
@export var entity: ZE_Character:
	set(value):
		entity = value
		_cached_perception = null
		_cache_perception()


# Components
var _cached_perception: ZC_Perception


func _cache_perception() -> ZC_Perception:
	if _cached_perception == null:
		_cached_perception = entity.get_component(ZC_Perception) as ZC_Perception
	return _cached_perception


func _ready() -> void:
	if vision_area != null:
		vision_area.body_sighted.connect(_on_vision_area_body_sighted)
		vision_area.body_hidden.connect(_on_vision_area_body_hidden)


func _calculate_visual_intensity(seen_entity: Entity) -> float:
	var distance := entity.global_position.distance_to(seen_entity.global_position) as float
	return clampf(1.0 - (distance / vision_area.range), 0.1, 1.0)


func _on_vision_area_body_sighted(body: Node) -> void:
	if not _cache_perception():
		return

	print("Zombie saw body: ", body.name)
	var seen_entity := CollisionUtils.get_collider_entity(body)
	if seen_entity == null:
		return

	if seen_entity.id not in _cached_perception.visible_entities:
		_cached_perception.visible_entities[seen_entity.id] = true

	# Create stimulus
	var intensity := _calculate_visual_intensity(seen_entity)
	var stimulus := ZC_Stimulus.saw_entity(seen_entity, intensity)
	entity.add_relationship(RelationshipUtils.make_detected(stimulus))


func _on_vision_area_body_hidden(body: Node) -> void:
	if not _cache_perception():
		return

	print("Zombie lost sight of body: ", body.name)
	var seen_entity := CollisionUtils.get_collider_entity(body)
	if seen_entity == null:
		return

	_cached_perception.visible_entities.erase(seen_entity.id)
