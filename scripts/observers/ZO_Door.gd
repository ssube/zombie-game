extends Observer
class_name ZO_DoorObserver

func watch() -> Resource:
	return ZC_Door


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant):
	var door := component as ZC_Door

	if property == 'is_open':
		var entity3d := entity.get_node(door.door_body) as Node3D

		if new_value:
			_open_door(entity, entity3d, door)

			if door.auto_close_time > 0:
				var close_timer := get_tree().create_timer(door.auto_close_time)
				close_timer.timeout.connect(_auto_close.bind(entity3d, door))
		else:
			_close_door(entity, entity3d, door)


func _tween_to_marker(entity3d: Node3D, marker: Marker3D, duration: float) -> Tween:
	var tween := entity3d.create_tween()
	tween.set_parallel()

	if not is_zero_approx(entity3d.position.distance_squared_to(marker.position)):
		tween.tween_property(entity3d, "position", marker.position, duration)
	if not is_zero_approx(entity3d.rotation.distance_squared_to(marker.rotation)):
		tween.tween_property(entity3d, "rotation", marker.rotation, duration)

	return tween


func _open_door(entity: Entity, entity3d: Node3D, door: ZC_Door) -> void:
	# TODO: figure out which way to swing
	# var open_marker_away := entity.get_node(door.open_marker_away) as Marker3D

	ZombieLogger.debug("Opening door: {0}", [entity.get_path()])
	var open_marker := entity.get_node(door.open_marker) as Marker3D
	_tween_to_marker(entity3d, open_marker, door.open_time)

	if door.open_effect:
		var effect := door.open_effect.instantiate() as Node3D
		entity3d.add_child(effect)


func _close_door(entity: Entity, entity3d: Node3D, door: ZC_Door) -> void:
	ZombieLogger.debug("Closing door: {0}", [entity.get_path()])
	var close_marker := entity.get_node(door.close_marker) as Marker3D
	_tween_to_marker(entity3d, close_marker, door.close_time)

	if door.close_effect:
		var effect := door.close_effect.instantiate() as Node3D
		entity3d.add_child(effect)


func _auto_close(_entity3d: Node3D, door: ZC_Door) -> void:
	door.is_open = false
