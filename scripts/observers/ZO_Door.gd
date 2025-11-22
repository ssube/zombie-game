extends Observer
class_name ZO_DoorObserver

func watch() -> Resource:
	return ZC_Door

func on_component_changed(entity: Entity, door: Resource, property: String, new_value: Variant, _old_value: Variant):
	if property == 'is_open':
		var entity3d := entity.get_node(".") as Node3D
		var tween := entity3d.create_tween()

		if new_value:
			print("Opening door")
			#if entity3d.position != door.open_position:
			#	tween.tween_property(entity3d, "position", door.open_position, 2.0)
			if entity3d.rotation != door.open_rotation:
				tween.tween_property(entity3d, "rotation", door.open_rotation, 2.0)
		else:
			print("Closing door")
			#if entity3d.position != door.close_position:
			#	tween.tween_property(entity3d, "position", door.close_position, 2.0)
			if entity3d.rotation != door.close_rotation:
				tween.tween_property(entity3d, "rotation", door.close_rotation, 2.0)
