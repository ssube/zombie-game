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
@export var screenshot_camera: Camera3D
@export_tool_button("Take Level Screenshot")
var take_screenshot_button = _take_level_screenshot


var _marker_cache: Dictionary[String, Marker3D] = {}


func _take_level_screenshot() -> void:
	if not Engine.is_editor_hint():
		ZombieLogger.error("Screenshot function should only be used in the editor.")
		return

	if screenshot_camera == null:
		ZombieLogger.error("No screenshot camera assigned.")
		return

	# Get the scene file path to derive the screenshot name
	var scene_path := self.scene_file_path
	if scene_path.is_empty():
		ZombieLogger.error("Scene has not been saved yet. Save the scene first.")
		return

	# Create a SubViewport to render from the screenshot camera
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)  # Adjust resolution as needed
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.transparent_bg = false

	# Clone the camera for the viewport
	var camera_copy := screenshot_camera.duplicate() as Camera3D
	camera_copy.current = true

	viewport.add_child(camera_copy)
	add_child(viewport)
	camera_copy.global_transform = screenshot_camera.global_transform
	ZombieLogger.info("Camera copy position: {0}", [camera_copy.global_position])

	# Force render update
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	RenderingServer.force_draw()

	# Wait for rendering to complete (in editor, we use call_deferred)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	# Capture the image
	var image := viewport.get_texture().get_image()

	# Clean up viewport
	viewport.queue_free()

	# Derive output path from scene path
	var scene_name := scene_path.get_file().get_basename()
	var output_dir := scene_path.get_base_dir()
	var output_path := output_dir.path_join(scene_name + ".png")

	# Save the image
	var error := image.save_png(output_path)
	if error != OK:
		ZombieLogger.error("Failed to save screenshot: {0}", [error])
		return

	ZombieLogger.info("Screenshot saved to: {0}", [output_path])

	# Refresh the filesystem so the image appears in the editor
	#if Engine.is_editor_hint():
	#	EditorInterface.get_resource_filesystem().scan()

func on_load() -> void:
	if screenshot_camera:
		screenshot_camera.queue_free()

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
