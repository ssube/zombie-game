class_name CollisionUtils


static var unknown_surface = &"unknown"


## Attempt to get the collider's entity, if the collider itself is not an entity.
## Checks the `parent_entity` field, then the node's immediate parent.
static func get_collider_entity(collider: Node) -> Entity:
	if collider == null:
		return null

	if collider is Entity:
		return collider

	if 'parent_entity' in collider:
		return collider.parent_entity

	var parent := collider.get_parent()
	if parent is Entity:
		return parent

	return null


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
	return node.get_meta("surface_type", "")


static func get_body_surface(body: Node) -> StringName:
	var surface_type := _get_surface_meta(body)
	if surface_type:
		return surface_type

	for child in body.get_children():
		if child is CollisionShape3D:
			surface_type = _get_surface_meta(child)
			if surface_type:
				return surface_type

	return unknown_surface


static func get_surface_type(raycast: RayCast3D) -> StringName:
	var shape := get_collision_shape(raycast)
	var surface_type := _get_surface_meta(shape)
	if surface_type:
		return surface_type

	var body := raycast.get_collider()
	surface_type = _get_surface_meta(body)
	if surface_type:
		return surface_type

	return unknown_surface


static func freeze_body_static(body: RigidBody3D) -> void:
	body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	body.freeze = true
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO


static func freeze_body_kinematic(body: RigidBody3D) -> void:
	body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	body.freeze = true
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO


static func unfreeze_body(body: RigidBody3D) -> void:
	body.freeze = false
