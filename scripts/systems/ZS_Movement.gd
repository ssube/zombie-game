class_name ZS_MovementSystem
extends System

func deps() -> Dictionary[int, Array]:
	return {
		Runs.After: [ZS_InputSystem],
		Runs.Before: [ZS_FootstepSystem],
	}

func query():
	return q.with_all([ZC_Movement, ZC_Velocity]).with_none([ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var movement: ZC_Movement = entity.get_component(ZC_Movement)
		var velocity: ZC_Velocity = entity.get_component(ZC_Velocity)
		var entity3d: Node3D = entity.get_node(".") as Node3D

		# Calculate speed modifiers from relationships
		var speed_multiplier: float = 1.0
		var modifiers = entity.get_relationships(RelationshipUtils.any_modifier)
		for modifier: Relationship in modifiers:
			if modifier.target is ZC_Effect_Speed:
				speed_multiplier *= modifier.target.multiplier

		velocity.speed_multiplier = speed_multiplier

		# Calculate direction to target position
		var current_pos := entity3d.global_position
		var target_pos := movement.target_move_position
		var to_target := target_pos - current_pos
		to_target.y = 0  # Horizontal movement only

		# Apply velocity from component to movement target
		if to_target.length_squared() < movement.target_proximity:
			velocity.linear_velocity = Vector3.ZERO
		else:
			velocity.linear_velocity = to_target.normalized()
