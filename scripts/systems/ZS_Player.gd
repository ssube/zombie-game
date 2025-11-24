class_name ZS_PlayerSystem
extends System

var last_shimmer: Dictionary = {} # dict for multiplayer

func query():
	return q.with_all([ZC_Transform, ZC_Velocity, ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, delta: float):
	for entity in entities:
		var transform = entity.get_component(ZC_Transform) as ZC_Transform
		var velocity = entity.get_component(ZC_Velocity) as ZC_Velocity
		var player = entity.get_component(ZC_Player) as ZC_Player
		var input = entity.get_component(ZC_Input) as ZC_Input

		var body := entity.get_node(".") as CharacterBody3D
		#body.rotation = input.turn_direction

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
		# TODO: fix infinite gravity
		if velocity.linear_velocity.y < 0:
			velocity.linear_velocity.y = max(velocity.gravity.y, velocity.linear_velocity.y)
		elif velocity.linear_velocity.y > 0:
			velocity.linear_velocity.y = min(velocity.gravity.y, velocity.linear_velocity.y)

		# Apply jump
		if input.move_jump:
				if abs(velocity.linear_velocity.y) < 0.1:
					velocity.linear_velocity.y = input.jump_speed

		# TODO: move this input the MovementSystem
		# Sync to CharacterBody3D (Node assumed attached to entity)
		body.velocity = velocity.linear_velocity
		body.move_and_slide()
		_handle_collisions(body, delta)

		# Pause menu
		if input.game_pause:
			%Hud.toggle_pause()

		# Spawn projectiles
		if input.use_attack:
			_spawn_projectile(entity, body)

		# Highlight interactive items
		var ray = entity.get_node(player.view_ray) as RayCast3D
		if ray.is_colliding():
			var collider = ray.get_collider()

			if collider != last_shimmer.get(entity):
				%Hud.reset_crosshair_color()
				remove_shimmer(entity)

			# Use interactive items
			if collider is Entity:
				if collider.has_component(ZC_Interactive):
					if not collider.has_component(ZC_Shimmer):
						var interactive = collider.get_component(ZC_Interactive) as ZC_Interactive
						var shimmer = ZC_Shimmer.from_interactive(interactive)
						collider.add_component(shimmer)
						last_shimmer[entity] = collider

					if collider.has_component(ZC_Food):
						%Hud.set_crosshair_color(Color.GREEN)
						if input.use_interact:
							use_food(collider, entity)

					if collider.has_component(ZC_Key):
						%Hud.set_crosshair_color(Color.YELLOW)
						if input.use_interact:
							use_key(collider, player)

					if collider.has_component(ZC_Door):
						%Hud.set_crosshair_color(Color.DODGER_BLUE)
						if input.use_interact:
							use_door(collider, player)

					if collider.has_component(ZC_Objective):
						%Hud.set_crosshair_color(Color.GOLD)
						if input.use_interact:
							use_objective(collider, player)

					if collider.has_component(ZC_Portal):
						%Hud.set_crosshair_color(Color.GOLD)
						if input.use_interact:
							use_portal(collider, entity)

		else:
			%Hud.reset_crosshair_color()
			remove_shimmer(entity)

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
	var marker = body.get_node("./Head/ProjectileMarker") as Node3D
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


func use_door(entity: Entity, player: ZC_Player) -> void:
	var door = entity.get_component(ZC_Door) as ZC_Door
	if door.is_locked:
		if player.has_key(door.key_name):
			door.is_locked = false
			print("Used key: ", door.key_name)
		else:
			print("Need key: ", door.key_name)

	if door.open_on_use and not door.is_locked:
		door.is_open = !door.is_open
		if entity.has_component(ZC_Open):
			entity.remove_component(ZC_Open)
		else:
			entity.add_component(ZC_Open.new())

		print("Door is open: ", door.is_open)


func use_food(entity: Entity, player_entity: Entity) -> void:
	var food = entity.get_component(ZC_Food) as ZC_Food
	var health = player_entity.get_component(ZC_Health) as ZC_Health
	health.current_health = min(health.max_health, health.current_health + food.health)
	print("Used food: ", entity)

	remove_entity(entity)


func use_key(entity: Entity, player: ZC_Player) -> void:
	var key = entity.get_component(ZC_Key)
	player.add_key(key.name)
	print("Added key: ", key.name)

	remove_entity(entity)


func use_objective(entity: Entity, _player: ZC_Player) -> void:
	var objective = entity.get_component(ZC_Objective) as ZC_Objective
	if objective.is_active:
		objective.is_complete = true
		print("Completed objective: ", objective)


func use_portal(entity: Entity, player_entity: Entity) -> void:
	var portal = entity.get_component(ZC_Portal) as ZC_Portal
	if portal.is_open:
		portal.is_active = true
		print("Activated portal: ", portal)


func remove_entity(entity: Entity) -> void:
	for shimmer_key in last_shimmer.keys():
		var shimmer_node = last_shimmer[shimmer_key]
		if entity == shimmer_node:
			last_shimmer.erase(shimmer_key)

	ECS.world.remove_entity(entity)
	entity.get_parent().remove_child(entity)
	entity.queue_free()


func remove_shimmer(entity: Entity) -> void:
	if entity in last_shimmer:
		var last_target = last_shimmer.get(entity)
		last_shimmer.erase(entity)

		if last_target == null:
			printerr("Removing shimmer from null entity: ", entity, last_target)
		else:
			last_target.remove_component(ZC_Shimmer)
