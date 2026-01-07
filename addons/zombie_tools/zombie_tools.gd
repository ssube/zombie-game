@tool
extends EditorPlugin

const DIAGRAM_FONT_SIZE = 16

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

var check_level_button: Button
var check_lock_keys_button: Button
var check_objective_keys_button: Button
var fix_mesh_scale_button: Button
var fix_mesh_rotation_button: Button
var sort_components_button: Button
var convert_ranged_to_thrown_button: Button
var generate_diagram_button: Button

func _enter_tree():
	fix_mesh_scale_button = Button.new()
	fix_mesh_scale_button.text = "Fix Collision Mesh Scale"
	fix_mesh_scale_button.pressed.connect(fix_collision_mesh_scale)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, fix_mesh_scale_button)

	fix_mesh_rotation_button = Button.new()
	fix_mesh_rotation_button.text = "Fix Collision Mesh Rotation"
	fix_mesh_rotation_button.pressed.connect(fix_collision_mesh_rotation)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, fix_mesh_rotation_button)

	sort_components_button = Button.new()
	sort_components_button.text = "Sort Components"
	sort_components_button.pressed.connect(sort_components)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, sort_components_button)

	check_lock_keys_button = Button.new()
	check_lock_keys_button.text = "Check Level Locks"
	check_lock_keys_button.pressed.connect(check_lock_keys)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, check_lock_keys_button)

	check_objective_keys_button = Button.new()
	check_objective_keys_button.text = "Check Level Objectives"
	check_objective_keys_button.pressed.connect(check_objective_keys)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, check_objective_keys_button)

	convert_ranged_to_thrown_button = Button.new()
	convert_ranged_to_thrown_button.text = "Convert Ranged Weapon to Thrown"
	convert_ranged_to_thrown_button.pressed.connect(convert_ranged_to_thrown)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, convert_ranged_to_thrown_button)

	check_level_button = Button.new()
	check_level_button.text = "Check Level Structure"
	check_level_button.pressed.connect(check_level_structure)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, check_level_button)

	generate_diagram_button = Button.new()
	generate_diagram_button.text = "Generate UI Diagram"
	generate_diagram_button.pressed.connect(generate_ui_diagram)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, generate_diagram_button)


func _exit_tree():
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, fix_mesh_scale_button)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, fix_mesh_rotation_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, sort_components_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, check_lock_keys_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, check_objective_keys_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, convert_ranged_to_thrown_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, check_level_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, generate_diagram_button)
	fix_mesh_scale_button.queue_free()
	fix_mesh_rotation_button.queue_free()
	sort_components_button.queue_free()
	check_lock_keys_button.queue_free()
	check_objective_keys_button.queue_free()
	convert_ranged_to_thrown_button.queue_free()
	check_level_button.queue_free()
	generate_diagram_button.queue_free()


func fix_collision_mesh_scale() -> void:
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	print("Checking meshes: ", selected)

	for selection in selected:
		if selection is CollisionShape3D:
			var shape = selection.shape
			if shape is ConvexPolygonShape3D: #  or shape is ConcavePolygonShape3D:
				var scale = selection.scale
				print("Fixing: ", shape, " with scale: ", scale)

				var points = shape.points.duplicate()
				var i = 0
				while i < points.size():
					var point = points.get(i)
					point *= scale
					points.set(i, point)
					i += 1

				print("Fixed %d points in shape" % i)
				shape.points = points
				selection.scale = Vector3.ONE
			else:
				print("Cannot fix shape type: ", shape)


func fix_collision_mesh_rotation() -> void:
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	print("Checking meshes for rotation: ", selected)

	for selection in selected:
		if selection is CollisionShape3D:
			var shape = selection.shape
			if shape is ConvexPolygonShape3D:
				var rotation_basis = selection.basis.orthonormalized()
				print("Fixing rotation: ", shape, " with rotation: ", selection.rotation_degrees)

				var points = shape.points.duplicate()
				var i = 0
				while i < points.size():
					var point = points.get(i)
					point = rotation_basis * point
					points.set(i, point)
					i += 1

				print("Rotated %d points in shape" % i)
				shape.points = points
				selection.rotation = Vector3.ZERO
			else:
				print("Cannot fix shape type: ", shape)


func _sort_component_class(a: Component, b: Component) -> int:
	var a_script := a.get_script() as Script
	var b_script := b.get_script() as Script
	var a_name := a_script.get_global_name()
	var b_name := b_script.get_global_name()

	return b_name < a_name


func sort_components() -> void:
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	print("Sorting components: ", selected)

	for selection in selected:
		if selection is Entity:
			selection.component_resources.sort_custom(_sort_component_class)
			print("Sorted %d components." % selection.component_resources.size())

		if selection is ZE_Base:
			selection.extra_components.sort_custom(_sort_component_class)
			print("Sorted %d extra components." % selection.extra_components.size())

	notify_property_list_changed()


func _find_child_entities(node: Node) -> Array[Entity]:
	var entities: Array[Entity] = []
	for child in node.get_children():
		if child is Entity:
			entities.append(child)

		var child_entities := _find_child_entities(child)
		entities.append_array(child_entities)

	return entities


func _find_child_objectives(node: Node) -> Array[ZN_BaseObjective]:
	var objectives: Array[ZN_BaseObjective] = []
	for child in node.get_children():
		if child is ZN_BaseObjective:
			objectives.append(child)

		var child_objectives := _find_child_objectives(child)
		objectives.append_array(child_objectives)

	return objectives


func _get_key_component(entity: Node) -> Component:
	# Check extras first because they override the resources
	for component in entity.extra_components:
		if component is ZC_Key:
			return component

	for component in entity.component_resources:
		if component is ZC_Key:
			return component

	return null


func _get_locked_component(entity: Node) -> Component:
	# Check extras first because they override the resources
	for component in entity.extra_components:
		if component is ZC_Locked:
			return component

	for component in entity.component_resources:
		if component is ZC_Locked:
			return component

	return null


func _get_objective_component(entity: Node) -> Component:
	# Check extras first because they override the resources
	for component in entity.extra_components:
		if component is ZC_Objective:
			return component

	for component in entity.component_resources:
		if component is ZC_Objective:
			return component

	return null


func check_lock_keys() -> void:
	# Find locked entities in the current scene and their corresponding keys
	var editor_interface := get_editor_interface()
	var scene_root := editor_interface.get_edited_scene_root() as Node3D
	if not scene_root:
		return

	#print("Current scene root: ", scene_root.name)
	var scene_entities := _find_child_entities(scene_root)

	var key_names: Array[String] = []
	var lock_keys: Array[String] = []

	for entity in scene_entities:
		#print("Checking entity: %s" % entity.name)
		var key := _get_key_component(entity) as ZC_Key
		var locked := _get_locked_component(entity) as ZC_Locked

		if key:
			#print("Found key: %s" % key.name)
			key_names.append(key.name)

		if locked:
			#print("Found locked: %s" % locked.key_name)
			lock_keys.append(locked.key_name)

	# Compare locks to keys
	var missing := 0
	for key_name in lock_keys:
		if key_name in key_names:
			print("Found key %s in the level." % key_name)
		else:
			# TODO: find a way to skip keys that are given in earlier levels
			printerr("Key %s does not exist in the level!" % key_name)
			missing += 1

	if missing == 0:
		print("Level has all %s keys." % key_names.size())
	else:
		printerr("Level is missing %d keys!" % missing)


func check_objective_keys() -> void:
	# Find objectives in the current scene and their corresponding keys
	var editor_interface := get_editor_interface()
	var scene_root := editor_interface.get_edited_scene_root() as Node3D
	if not scene_root:
		return

	#print("Current scene root: ", scene_root.name)
	var scene_entities := _find_child_entities(scene_root)
	var scene_objectives := _find_child_objectives(scene_root)

	var objective_names: Array[String] = []

	for objective in scene_objectives:
		print("Found objective: %s" % objective.key)
		objective_names.append(objective.key)

	var missing := 0
	for entity in scene_entities:
		var objective := _get_objective_component(entity) as ZC_Objective

		if not objective:
			continue

		if objective.key == "":
			printerr("Objective component on entity %s has an empty key!" % entity.name)
			continue

		if objective.key in objective_names:
			print("Found objective %s in the level." % objective.key)
		else:
			missing += 1
			printerr("Objective %s does not exist in the level!" % objective.key)

	if missing == 0:
		print("Level has all %d objectives." % objective_names.size())
	else:
		printerr("Level is missing %d objectives!" % missing)


func serialize(component: Component) -> Dictionary:
	var data: Dictionary = {}
	for prop_info in component.get_script().get_script_property_list():
		# Only include properties that are exported (@export variables)
		if prop_info.usage & PROPERTY_USAGE_EDITOR:
			var prop_name: String = prop_info.name
			var prop_val = component.get(prop_name)
			data[prop_name] = prop_val
	return data


func convert_ranged_to_thrown() -> void:
	var editor_interface := get_editor_interface()
	var scene_root := editor_interface.get_edited_scene_root() as Node3D
	if not scene_root:
		return

	# get selected entities
	var selected = editor_interface.get_selection().get_selected_nodes()
	print("Converting selected entities: ", selected)

	for selection in selected:
		if selection is Entity:
			var entity := selection as Entity

			var has_ranged := false
			for component in entity.component_resources.duplicate():
				if component is ZC_Weapon_Ranged:
					has_ranged = true
					var ranged_component := component as ZC_Weapon_Ranged
					var thrown_component := ZC_Weapon_Thrown.new()

					# Copy properties from ranged to thrown
					var ranged_data := serialize(ranged_component)
					for key in ranged_data.keys():
						print("Copying property %s" % key)
						thrown_component.set(key, ranged_data[key])

					# Remove the ranged component and add the thrown component
					entity.component_resources.erase(ranged_component)
					entity.component_resources.append(thrown_component)

			if has_ranged:
				print("Converted entity %s from Ranged to Thrown weapon." % entity.name)
			else:
				print("Entity %s does not have a Ranged weapon component." % entity.name)


func check_level_structure() -> void:
	var editor_interface := get_editor_interface()
	var scene_root := editor_interface.get_edited_scene_root() as ZN_Level
	if not scene_root:
		printerr("Current scene is not a ZN_Level!")
		return

	print("Checking level structure for: ", scene_root.name)

	var errors := false
	var warnings := false

	if scene_root.level_actions:
		if scene_root.level_actions.actions.size() == 0:
			printerr("Level actions exist but contain no actions!")
			errors = true
		else:
			print("Level has %d actions." % scene_root.level_actions.actions.size())

	var areas_node = scene_root.get_node(scene_root.areas_node) as Node
	if not areas_node:
		push_warning("Areas node not found at path: %s" % scene_root.areas_node)
		warnings = true
	else:
		print("Areas node found: %s" % areas_node.name)

	var entities_node = scene_root.get_node(scene_root.entities_node) as Node
	if not entities_node:
		printerr("Entities node not found at path: %s" % scene_root.entities_node)
		errors = true
	else:
		print("Entities node found: %s" % entities_node.name)

	var lights_node = scene_root.get_node(scene_root.lights_node) as Node
	if not lights_node:
		push_warning("Lights node not found at path: %s" % scene_root.lights_node)
		warnings = true
	else:
		print("Lights node found: %s" % lights_node.name)

	var markers_node = scene_root.get_node(scene_root.markers_node) as Node
	if not markers_node:
		printerr("Markers node not found at path: %s" % scene_root.markers_node)
		errors = true
	else:
		print("Markers node found: %s" % markers_node.name)

	var map_node = scene_root.get_node(scene_root.map_node) as Node
	if not map_node:
		printerr("Map node not found at path: %s" % scene_root.map_node)
		errors = true
	else:
		print("Map node found: %s" % map_node.name)

	var objectives_node = scene_root.get_node(scene_root.objectives_node) as Node
	if not objectives_node:
		push_warning("Objectives node not found at path: %s" % scene_root.objectives_node)
		warnings = true
	else:
		print("Objectives node found: %s" % objectives_node.name)

	var environment_node = scene_root.get_node(scene_root.environment_node) as Node
	if not environment_node:
		push_warning("Environment node not found at path: %s" % scene_root.environment_node)
		warnings = true
	else:
		print("Environment node found: %s" % environment_node.name)

	var level_entities := _find_child_entities(entities_node)

	# make sure all of the entity children are under the entities node
	if entities_node:
		var scene_entities := _find_child_entities(scene_root)
		var missing_entities := 0
		for entity in scene_entities:
			if entity not in level_entities:
				printerr("Entity %s is not under the entities node!" % entity.get_path())
				errors = true
				missing_entities += 1

		if missing_entities == 0:
			print("All %d entities are under the entities node." % scene_entities.size())
		else:
			printerr("Level is missing %d entities under the entities node!" % missing_entities)

	# check for invalid node paths
	var root_name := scene_root.name
	var bad_prefix := "../%s/" % root_name

	for entity in level_entities:
		for component in entity.component_resources:
			#print("Checking component: %s" % component.get_script().get_global_name())
			var properties := component.get_property_list()
			#print("Found %d exported properties." % properties.size())
			#print(JSON.stringify(properties))

			for property in properties:
				if property.get("usage", 0) & (PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR):
					var value = component.get(property["name"])
					if value is NodePath:
						var path: NodePath = value as NodePath
						var path_str: String = str(path)

						# TODO: check for empty paths
						if path_str.begins_with(bad_prefix):
							printerr("Component %s on entity %s has invalid NodePath: %s" % [
								component.get_script().get_global_name(),
								entity.name,
								path_str,
							])
							errors = true
						else:
							print("NodePath is valid: %s" % path_str)

	print("Level structure check complete.")

	if errors:
		printerr("Level structure has errors!")
	elif warnings:
		push_warning("Level structure has warnings!")
	else:
		print("Level structure is valid!")


func _find_all_nodes(node: Node) -> Array[Node]:
	var nodes: Array[Node] = [node]
	for child in node.get_children():
		nodes.append_array(_find_all_nodes(child))
	return nodes


func generate_ui_diagram() -> void:
	var editor_interface := get_editor_interface()
	var scene_root := editor_interface.get_edited_scene_root()
	if not scene_root:
		printerr("No scene is currently loaded!")
		return

	# Get the size of the root control
	var root_size: Vector2
	if scene_root is Control:
		root_size = scene_root.size
	else:
		printerr("Scene root is not a Control node! Cannot generate diagram.")
		return

	if root_size.x <= 0 or root_size.y <= 0:
		printerr("Scene root has invalid size: %v" % root_size)
		return

	print("Generating diagram for scene: %s (size: %v)" % [scene_root.name, root_size])

	# Find all nodes in the scene
	var all_nodes := _find_all_nodes(scene_root)
	print("Found %d nodes in scene" % all_nodes.size())

	# Collect diagram elements
	var diagram_elements := []
	var diagram_count := 0

	for node in all_nodes:
		if not node is Control:
			continue

		var control := node as Control

		# Check for diagram metadata
		var diagram_label := ""
		var diagram_outline: Color = Color.TRANSPARENT

		if node.has_meta("diagram_label"):
			diagram_label = str(node.get_meta("diagram_label"))

		if node.has_meta("diagram_outline"):
			var meta_value = node.get_meta("diagram_outline")
			if meta_value is Color:
				diagram_outline = meta_value
			elif meta_value is String:
				diagram_outline = Color(meta_value)

		# Skip if no diagram metadata
		if diagram_label == "" and diagram_outline == Color.TRANSPARENT:
			continue

		diagram_count += 1
		print("Processing diagram node: %s (label: '%s', outline: %s)" % [node.name, diagram_label, diagram_outline])

		# Get the control's global rect
		var rect := control.get_global_rect()

		# Add to diagram elements
		diagram_elements.append({
			"rect": rect,
			"label": diagram_label,
			"outline": diagram_outline
		})

	print("Processed %d diagram elements" % diagram_count)

	# Create a SubViewport for rendering
	var viewport := SubViewport.new()
	viewport.size = Vector2i(int(root_size.x), int(root_size.y))
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	# Load and create the diagram canvas
	var DiagramCanvas := load("res://addons/zombie_tools/diagram_canvas.gd")
	var canvas = DiagramCanvas.new()
	canvas.size = root_size
	canvas.diagram_elements = diagram_elements
	canvas.diagram_font_size = DIAGRAM_FONT_SIZE

	viewport.add_child(canvas)
	add_child(viewport)

	# Trigger drawing
	canvas.queue_redraw()

	# Wait for render
	await RenderingServer.frame_post_draw

	# Get the rendered image
	var image := viewport.get_texture().get_image()

	# Clean up
	viewport.queue_free()

	if not image:
		printerr("Failed to capture image from viewport!")
		return

	# Save the image
	var scene_path := scene_root.scene_file_path
	if scene_path == "":
		printerr("Scene has not been saved yet! Cannot determine output path.")
		return

	var output_path := scene_path.get_basename() + ".png"

	var err := image.save_png(output_path)
	if err != OK:
		printerr("Failed to save diagram to: %s (error: %d)" % [output_path, err])
	else:
		print("Diagram saved to: %s" % output_path)
