extends System
class_name ZS_PathFollowSystem


func query() -> QueryBuilder:
	return q.with_all([ZC_PathFollow])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var path_follow: ZC_PathFollow = entity.get_component(ZC_PathFollow)
		if not path_follow.active:
			continue

		path_follow.elapsed_time += delta
		var t: float = path_follow.elapsed_time / path_follow.duration
		if t > 1.0:
			if path_follow.loop:
				path_follow.elapsed_time -= path_follow.duration
				t -= 1.0
			else:
				t = 1.0
				path_follow.active = false

		var path_node := entity.get_node(path_follow.path) as Path3D
		if path_node == null:
			ZombieLogger.warning("PathFollow component on entity %s has an invalid path node." % entity.name)
			continue

		var offset_t := t + path_follow.offset
		offset_t = fmod(offset_t, 1.0)

		var distance := path_node.curve.get_baked_length() * offset_t
		var transform := path_node.curve.sample_baked_with_rotation(distance)
		transform.origin += path_node.global_position
		entity.global_transform = transform

		if path_follow.look_ahead:
			var look_ahead_distance: float = distance + path_follow.look_ahead_distance
			var look_ahead_transform: Transform3D = path_node.curve.sample_baked_with_rotation(look_ahead_distance)
			look_ahead_transform.origin += path_node.global_position

			var direction: Vector3 = (look_ahead_transform.origin - transform.origin).normalized()
			if not is_zero_approx(direction.length_squared()):
				entity.look_at(look_ahead_transform.origin, Vector3.UP, true)
