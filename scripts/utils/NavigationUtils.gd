class_name NavigationUtils

static func follow_navigation_path(entity: Node3D, navigation_path: PackedVector3Array, point_proximity: float) -> void:
	if len(navigation_path) == 0:
		return

	var next_point := navigation_path[0]
	if NavigationUtils.is_point_nearby(entity, next_point, point_proximity):
		navigation_path.remove_at(0)
	else:
		entity.move_to_target(next_point)

## Check if the node is close to a point
static func is_point_nearby(entity: Node3D, point: Vector3, proximity: float) -> bool:
	if entity == null:
		return false

	var distance: float = entity.global_position.distance_to(point)
	return distance <= proximity

## Get a random position on the navigation map within radius of the node's current position
static func pick_random_position(entity: Node3D, radius: float) -> Vector3:
	var origin: Vector3 = entity.global_position
	var random_x := randf_range(origin.x - radius, origin.x + radius)
	var random_z := randf_range(origin.z - radius, origin.z + radius)
	var random_point: Vector3 = Vector3(random_x, origin.y, random_z)

	var default_map_rid: RID = entity.get_world_3d().get_navigation_map()

	return NavigationServer3D.map_get_closest_point(
		default_map_rid,
		random_point
	)

static func update_navigation_path(entity: Node3D, nav_target_position: Vector3) -> PackedVector3Array:
	assert(entity != null, "Entity must not be null")
	assert(entity.is_inside_tree(), "Entity must be inside the scene tree")

	var default_map_rid: RID = entity.get_world_3d().get_navigation_map()
	return NavigationServer3D.map_get_path(
		default_map_rid,
		entity.global_position,
		nav_target_position,
		true
	)
