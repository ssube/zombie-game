class_name CollisionUtils


static func get_collision_shape(raycast: RayCast3D) -> CollisionShape3D:
	if not raycast.is_colliding():
		return null

	var target = raycast.get_collider()
	if not target is CollisionObject3D:
		return null

	var target_shape = target as CollisionObject3D
	var shape_id = raycast.get_collider_shape()
	var owner_id = target_shape.shape_find_owner(shape_id)
	var shape = target_shape.shape_owner_get_owner(owner_id)
	if shape is CollisionShape3D:
		return shape

	return null


static func get_shape_body(shape: CollisionShape3D) -> CollisionObject3D:
	var parent := shape.get_parent()
	assert(parent is CollisionObject3D, "Shape parent should be a collision object!")
	return parent


static func _get_surface_meta(node: Node) -> StringName:
	return node.get_meta("surface_type", "unknown")


static func get_surface_type(raycast: RayCast3D) -> StringName:
	var shape := get_collision_shape(raycast)
	var surface_type := _get_surface_meta(shape)
	if surface_type != null:
		return surface_type

	var body := raycast.get_collider()
	surface_type = _get_surface_meta(body)
	if surface_type != null:
		return surface_type

	return &"unknown"
