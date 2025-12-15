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

		var skin_material: BaseMaterial3D
		match new_value:
			ZC_Skin.SkinType.DEAD:
				skin_material = skin.material_dead
			ZC_Skin.SkinType.HEALTHY:
				skin_material = skin.material_healthy
			ZC_Skin.SkinType.HURT:
				skin_material = skin.material_hurt

		assert(skin_material != null, "Skin material is missing!")
		update_skin_material(entity, skin, skin_material)


func update_skin_material(entity: Node, skin: ZC_Skin, material: BaseMaterial3D):
	for shape_path in skin.skin_shapes:
		var shape = entity.get_node(shape_path) as GeometryInstance3D
		shape.material_overlay = material
