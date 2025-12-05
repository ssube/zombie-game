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

static func get_shape_components(entity: Node, raycast: RayCast3D) -> Array[Component]:
	if not entity is Entity:
		return []

	var collision_shape := CollisionUtils.get_collision_shape(raycast)
	var e_entity := entity as Entity
	var critical_relationships := e_entity.get_relationships(Relationship.new(null, null)) # TODO: ZC_Critical -> any
	for relationship in critical_relationships:
		var shape = relationship.target.shape

		if shape == collision_shape:
			var shape_components = relationship.target.components as Array[Component]
			return shape_components.duplicate_deep()

	return []
