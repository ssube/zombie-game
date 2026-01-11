extends Observer
class_name ZO_SkinObserver


const _hidden_groups: Dictionary[String, Array] = {
	"skin_dead": ["skin_healthy", "skin_hurt"],
	"skin_healthy": ["skin_dead", "skin_hurt"],
	"skin_hurt": ["skin_dead", "skin_healthy"],
	"skin_disabled": ["skin_enabled"],
	"skin_enabled": ["skin_disabled"],
}


func watch() -> Resource:
	return ZC_Skin


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	var skin := component as ZC_Skin
	assert(skin != null, "Skin observer is expecting a skin component!")

	if property == "current_skin":
		var old_name := ZC_Skin.SkinType.keys()[old_value] as String
		var new_name := ZC_Skin.SkinType.keys()[new_value] as String
		ZombieLogger.debug("Current skin changed from {0} to {1}", [old_name, new_name])

		# TODO: find a better way to hide old groups
		var hide_groups: Array = []
		var skin_group: String
		var skin_material: BaseMaterial3D
		match new_value:
			ZC_Skin.SkinType.DEAD:
				skin_group = "skin_dead"
				skin_material = skin.material_dead
			ZC_Skin.SkinType.HEALTHY:
				skin_group = "skin_healthy"
				skin_material = skin.material_healthy
			ZC_Skin.SkinType.HURT:
				skin_group = "skin_hurt"
				skin_material = skin.material_hurt
			ZC_Skin.SkinType.DISABLED:
				skin_group = "skin_disabled"
				skin_material = skin.material_disabled
			ZC_Skin.SkinType.ENABLED:
				skin_group = "skin_enabled"
				skin_material = skin.material_enabled

		if skin_material:
			update_skin_material.call_deferred(entity, skin, skin_material)

		hide_groups = _hidden_groups[skin_group]
		show_skin_group.call_deferred(entity, skin_group, hide_groups)


func update_skin_material(entity: Node, skin: ZC_Skin, material: BaseMaterial3D):
	# TODO: add an option to use the overlay or override material slots
	for shape_path in skin.skin_shapes:
		var shape = entity.get_node(shape_path) as GeometryInstance3D
		# shape.material_overlay = material
		shape.material_override = material

	# TODO: do this search once, combine with show_skin_group
	var all_children := entity.find_children("*", "GeometryInstance3D", true, false)
	for child in all_children:
		if child.is_in_group("skin_material"):
			if child is GeometryInstance3D:
				var geom_instance := child as GeometryInstance3D
				# geom_instance.material_overlay = material
				geom_instance.material_override = material


func show_skin_group(entity: Node, show_group: String, hide_groups: Array = []) -> void:
	var all_children := entity.find_children("*", "", true, false)
	for child in all_children:
		if child.is_in_group(show_group):
			TreeUtils.toggle_node(child, TreeUtils.ALL_FLAGS, TreeUtils.ALL_FLAGS)

		for hide_group: String in hide_groups:
			if child.is_in_group(hide_group):
				TreeUtils.toggle_node(child, TreeUtils.NodeState.NONE, TreeUtils.ALL_FLAGS)
