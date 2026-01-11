@tool
extends Node3D
class_name ZN_Level

@export_group("Hooks")
@export var level_actions: ZC_Action

@export_group("Pointers")
@export var areas_node: NodePath = "Areas"
@export var entities_node: NodePath = "Entities"
@export var lights_node: NodePath = "Lights"
@export var markers_node: NodePath = "Markers"
@export var map_node: NodePath = "Map"
@export var objectives_node: NodePath = "Objectives"

@export_subgroup("Environment")
@export var environment_node: NodePath = "Environment"
@export var environment_scenes: Array[ZR_Weather] = []

# TODO: extra observers
# TODO: extra systems

@export_group("Screenshots")
@export var screenshot_cameras: Array[Camera3D] = []


var _marker_cache: Dictionary[String, Marker3D] = {}


func on_load() -> void:
	for camera in screenshot_cameras:
		if camera:
			camera.queue_free()

	apply_shadow_settings()

	if level_actions:
		ActionUtils.run_component(level_actions, self, Enums.ActionEvent.LEVEL_LOAD, null)


func apply_shadow_settings() -> void:
	var shadow_count := OptionsManager.options.graphics.shadow_count

	# Get nodes from shadow groups
	var shadow_low_nodes := get_tree().get_nodes_in_group("shadow_low")
	var shadow_high_nodes := get_tree().get_nodes_in_group("shadow_high")

	# Determine which shadows should be enabled based on shadow_count setting
	# NONE (0): all shadows disabled
	# LOW (1): shadow_low enabled, shadow_high disabled
	# HIGH (3): both enabled
	var enable_low := shadow_count >= ZR_GraphicsOptions.ShadowCount.LOW
	var enable_high := shadow_count >= ZR_GraphicsOptions.ShadowCount.HIGH

	for node in shadow_low_nodes:
		if node is Light3D:
			node.shadow_enabled = enable_low

	for node in shadow_high_nodes:
		if node is Light3D:
			node.shadow_enabled = enable_high


func cache_markers() -> void:
	clear_markers()
	var markers := self.get_node(markers_node).get_children()
	for marker in markers:
		if marker is Marker3D:
			_marker_cache[marker.name] = marker


func clear_markers() -> void:
	_marker_cache.clear()


func add_marker(key: String, marker: Marker3D) -> void:
	_marker_cache[key] = marker


func get_marker(key: String) -> Marker3D:
	var markers := get_markers()
	return markers.get(key, null)


func get_markers() -> Dictionary[String, Marker3D]:
	var markers := _marker_cache.duplicate()

	var group_markers := self.get_tree().get_nodes_in_group("level_markers")
	for marker in group_markers:
		if marker is Marker3D:
			# if marker.name not in markers:
			markers[marker.name] = marker as Marker3D

	return markers


func remove_marker(key: String) -> void:
	_marker_cache.erase(key)
