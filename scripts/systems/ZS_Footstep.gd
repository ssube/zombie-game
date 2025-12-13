extends System
class_name ZS_FootstepSystem

var _next_footsteps: Dictionary[String, float] = {}

func query() -> QueryBuilder:
	return q.with_all([ZC_Footstep, ZC_Velocity])

func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0

	for entity in entities:
		var footstep := entity.get_component(ZC_Footstep) as ZC_Footstep

		var next_footstep := _next_footsteps.get(entity.id, 0.0) as float
		if now < next_footstep:
			continue

		var health := entity.get_component(ZC_Health) as ZC_Health
		if health:
			if health.current_health <= 0:
				continue

		var velocity := entity.get_component(ZC_Velocity) as ZC_Velocity
		var horizontal_velocity := velocity.linear_velocity
		horizontal_velocity.y = 0

		if is_zero_approx(horizontal_velocity.length_squared()):
			continue

		var raycast := entity.get_node(footstep.raycast) as RayCast3D
		if not raycast.is_colliding():
			continue

		var surface_type := CollisionUtils.get_surface_type(raycast)
		var step_sound := footstep.sounds.get(surface_type) as PackedScene
		if step_sound == null:
			continue

		var new_footstep := step_sound.instantiate() as Node3D
		var collider := raycast.get_collider() as Node3D
		var collision_point := raycast.get_collision_point()

		collider.add_child(new_footstep)
		new_footstep.global_position = collision_point

		var next_variation = randf_range(-footstep.variation, +footstep.variation)
		next_footstep = now + next_variation + footstep.interval
		_next_footsteps[entity.id] = next_footstep
