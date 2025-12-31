@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

var check_lock_keys_button: Button
var check_objective_keys_button: Button
var fix_mesh_scale_button: Button
var fix_mesh_rotation_button: Button
var sort_components_button: Button
var convert_ranged_to_thrown_button: Button

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
	check_lock_keys_button.text = "Check Lock Keys"
	check_lock_keys_button.pressed.connect(check_lock_keys)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, check_lock_keys_button)

	check_objective_keys_button = Button.new()
	check_objective_keys_button.text = "Check Objective Keys"
	check_objective_keys_button.pressed.connect(check_objective_keys)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, check_objective_keys_button)

	convert_ranged_to_thrown_button = Button.new()
	convert_ranged_to_thrown_button.text = "Convert Ranged to Thrown"
	convert_ranged_to_thrown_button.pressed.connect(convert_ranged_to_thrown)
	add_control_to_container(CONTAINER_INSPECTOR_BOTTOM, convert_ranged_to_thrown_button)


func _exit_tree():
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, fix_mesh_scale_button)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, fix_mesh_rotation_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, sort_components_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, check_lock_keys_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, check_objective_keys_button)
	remove_control_from_container(CONTAINER_INSPECTOR_BOTTOM, convert_ranged_to_thrown_button)
	fix_mesh_scale_button.queue_free()
	fix_mesh_rotation_button.queue_free()
	sort_components_button.queue_free()
	check_lock_keys_button.queue_free()
	check_objective_keys_button.queue_free()
	convert_ranged_to_thrown_button.queue_free()


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