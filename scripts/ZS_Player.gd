class_name ZS_PlayerSystem
extends System

func query():
	# Find all entities that have both transform and velocity
	return q.with_all([ZC_Transform, ZC_Velocity, ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, delta: float):
	# Process each entity in the array
	for entity in entities:
		var transform = entity.get_component(ZC_Transform) as ZC_Transform
		var velocity = entity.get_component(ZC_Velocity) as ZC_Velocity
		var input = entity.get_component(ZC_Input) as ZC_Input
		
		var body := entity.get_node(".") as CharacterBody3D
		body.rotation = input.turn_direction
		
		var forward = -body.global_transform.basis.z.normalized()
		var right = body.global_transform.basis.x.normalized()

		var direction = (
				(right * input.move_direction.x) + 
				(forward * input.move_direction.y)
		).normalized()
		var speed = input.walk_speed

		if input.move_sprint:
			speed *= input.sprint_multiplier
		elif input.move_crouch:
			speed *= input.crouch_multiplier

		var horizontal_velocity = direction * speed
		print("hvel", horizontal_velocity, input.move_direction, speed)

		# Apply horizontal velocity, retain vertical velocity
		velocity.linear_velocity.x = horizontal_velocity.x
		velocity.linear_velocity.z = horizontal_velocity.z

		# Apply gravity
		velocity.linear_velocity += velocity.gravity * delta

		# Apply jump
		if input.move_jump and abs(velocity.linear_velocity.y) < 0.1:
			velocity.linear_velocity.y = input.jump_speed

		# TODO: move this input the MovementSystem
		# Sync to CharacterBody3D (Node assumed attached to entity)
		body.velocity = velocity.linear_velocity
		body.move_and_slide()

		# Update ECS transform from actual node position
		transform.position = body.global_position
		transform.rotation = body.rotation
