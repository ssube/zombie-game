extends System
class_name ZS_FootstepSystem

@export var sprint_multiplier: float = 2.0

var _footstep_timers: Dictionary[String, float] = {}

func query() -> QueryBuilder:
	return q.with_all([ZC_Footstep, ZC_Velocity])

func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var footstep := entity.get_component(ZC_Footstep) as ZC_Footstep

		var footstep_timer := _footstep_timers.get(entity.id, 0.0) as float
		footstep_timer -= delta

		if footstep_timer > 0:
			_footstep_timers[entity.id] = footstep_timer
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

		# TODO: reset the timer when the entity starts sprinting
		var input := entity.get_component(ZC_Input) as ZC_Input
		if input and input.move_sprint:
			footstep_timer = next_variation + footstep.sprint_interval
		elif input and input.move_crouch:
			footstep_timer = next_variation + footstep.crouch_interval
		else:
			footstep_timer = next_variation + footstep.walk_interval

		_footstep_timers[entity.id] = footstep_timer
