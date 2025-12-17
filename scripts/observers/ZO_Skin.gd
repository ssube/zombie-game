extends Observer
class_name ZO_SkinObserver

func watch() -> Resource:
	return ZC_Skin


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	var skin := component as ZC_Skin
	assert(skin != null, "Skin observer is expecting a skin component!")

	print("Skin changed for entity %s: %s" % [entity.id, property])
	if property == "current_skin":
		print("Current skin changed from %d to %d" % [old_value, new_value])

		# TODO: find a better way to hide old groups
		var hide_groups: Array[String] = []
		var skin_group: String
		var skin_material: BaseMaterial3D
		match new_value:
			ZC_Skin.SkinType.DEAD:
				hide_groups = ["skin_healthy", "skin_hurt"]
				skin_group = "skin_dead"
				skin_material = skin.material_dead
			ZC_Skin.SkinType.HEALTHY:
				hide_groups = ["skin_dead", "skin_hurt"]
				skin_group = "skin_healthy"
				skin_material = skin.material_healthy
			ZC_Skin.SkinType.HURT:
				hide_groups = ["skin_dead", "skin_healthy"]
				skin_group = "skin_hurt"
				skin_material = skin.material_hurt

		# assert(skin_material != null, "Skin material is missing!")
		if skin_material:
			update_skin_material.call_deferred(entity, skin, skin_material)
		show_skin_group.call_deferred(entity, skin_group, hide_groups)


func update_skin_material(entity: Node, skin: ZC_Skin, material: BaseMaterial3D):
	for shape_path in skin.skin_shapes:
		var shape = entity.get_node(shape_path) as GeometryInstance3D
		shape.material_overlay = material


func show_skin_group(entity: Node, show_group: String, hide_groups: Array[String] = []) -> void:
	var all_children := entity.find_children("*")
	for child in all_children:
		if child.is_in_group(show_group):
			_toggle_node(child, true)

		for hide_group in hide_groups:
			if child.is_in_group(hide_group):
				_toggle_node(child, false)


func _toggle_node(node: Node, value: bool) -> void:
	if "active" in node:
		node.active = value

	if "visible" in node:
		node.visible = value

	if "disabled" in node:
		node.disabled = not node

	if "process_mode" in node:
		if value:
			node.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			node.process_mode = Node.PROCESS_MODE_DISABLED
