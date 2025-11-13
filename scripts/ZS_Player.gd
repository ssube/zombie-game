class_name ZS_PlayerSystem
extends System

func query():
	return q.with_all([ZC_Transform, ZC_Velocity, ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, delta: float):
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
		_handle_collisions(body, delta)

		# Spawn projectiles
		if input.use_attack:
			_spawn_projectile(entity, body)

		# Update ECS transform from actual node position
		transform.position = body.global_position
		transform.rotation = body.rotation

func _handle_collisions(body: CharacterBody3D, delta: float) -> void:
	for collision_index in body.get_slide_collision_count():
		var collision: KinematicCollision3D = body.get_slide_collision(collision_index)
		var collider: Node3D = collision.get_collider()
		var position: Vector3 = collision.get_position()

		if collider is RigidBody3D:
			var push_direction := -collision.get_normal()
			var push_position = position - collider.global_position
			collider.apply_impulse(push_direction * 50 * delta, push_position)

func _spawn_projectile(entity: Entity, body: CharacterBody3D) -> void:
	var marker = body.get_node("./ProjectileMarker") as Node3D
	var weapon = entity.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged

	if marker != null and weapon != null:
		var forward = -marker.global_transform.basis.z.normalized()

		var new_projectile = weapon.projectile_scene.instantiate() as RigidBody3D
		body.get_parent().add_child(new_projectile)

		if new_projectile is Entity:
			ECS.world.add_entity(new_projectile)
		else:
			printerr("Projectile is not an entity: ", new_projectile)

		new_projectile.global_position = marker.global_position
		new_projectile.global_rotation = marker.global_rotation
		new_projectile.apply_impulse(forward * weapon.muzzle_velocity, body.global_position)
