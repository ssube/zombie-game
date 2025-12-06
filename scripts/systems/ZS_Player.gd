class_name ZS_PlayerSystem
extends System

var last_shimmer: Dictionary[Entity, Entity] = {} # dict for multiplayer

func query():
	return q.with_all([ZC_Transform, ZC_Velocity, ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, delta: float):
	for entity in entities:
		var transform = entity.get_component(ZC_Transform) as ZC_Transform
		var velocity = entity.get_component(ZC_Velocity) as ZC_Velocity
		var player = entity.get_component(ZC_Player) as ZC_Player
		var input = entity.get_component(ZC_Input) as ZC_Input
		var modifiers = entity.get_relationships(RelationshipUtils.any_modifier)

		var speed_multiplier := 1.0
		for modifier: Relationship in modifiers:
			if modifier.target is ZC_Effect_Speed:
				speed_multiplier *= modifier.target.multiplier

		var body := entity.get_node(".") as CharacterBody3D
		body.rotation.x += input.turn_direction.x
		body.rotation.y += input.turn_direction.y
		body.rotation.z = input.turn_direction.z

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

		# Apply jump
		if input.move_jump:
			if body.is_on_floor():
				velocity.linear_velocity.y = input.jump_speed

		# TODO: move this input the MovementSystem
		# Sync to CharacterBody3D (Node assumed attached to entity)
		body.velocity = velocity.linear_velocity * speed_multiplier
		body.move_and_slide()
		_handle_collisions(body, delta)

		# Move weapon to follow hands
		if entity.current_weapon != null:
			var weapon_body = entity.current_weapon.get_node(".") as RigidBody3D
			weapon_body.global_transform = entity.hands_node.global_transform

		# Pause menu
		if input.game_pause:
			%Hud.toggle_pause()

		# Weapon switching
		if input.weapon_next:
			equip_next_weapon(entity as ZE_Player)
		elif input.weapon_previous:
			equip_previous_weapon(entity as ZE_Player)

		# Spawn projectiles
		if input.use_attack:
			if entity.current_weapon != null:
				if entity.current_weapon.has_component(ZC_Weapon_Melee):
					swing_weapon(entity, body)
				if entity.current_weapon.has_component(ZC_Weapon_Ranged):
					spawn_projectile(entity, body)

		if input.use_light:
			toggle_flashlight(entity, body)

		# Highlight interactive items
		var ray = entity.get_node(player.view_ray) as RayCast3D
		if ray.is_colliding():
			var collider = ray.get_collider()

			if collider != last_shimmer.get(entity) and collider != entity.current_weapon:
				%Hud.clear_target_label()
				%Hud.reset_crosshair_color()
				remove_shimmer(entity)

			# Use interactive items
			if collider is Entity and collider != entity.current_weapon:
				if EntityUtils.is_interactive(collider):
					var interactive = collider.get_component(ZC_Interactive) as ZC_Interactive
					%Hud.set_target_label(interactive.name)

					if not EntityUtils.has_shimmer(collider):
						var shimmer = ZC_Shimmer.from_interactive(interactive)
						collider.add_component(shimmer)
						last_shimmer[entity] = collider

					if collider is ZE_Character:
						if input.use_interact:
							use_character(collider, entity)

					if collider.has_component(ZC_Objective):
						%Hud.set_crosshair_color(Color.GOLD)
						if input.use_interact:
							use_objective(collider, player)

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

					if collider.has_component(ZC_Portal):
						%Hud.set_crosshair_color(Color.GOLD)
						if input.use_interact:
							use_portal(collider, entity)

					if EntityUtils.is_weapon(collider):
						%Hud.set_crosshair_color(Color.ORANGE)
						if input.use_interact:
							use_weapon(collider, entity)
		else:
			%Hud.clear_target_label()
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


func swing_weapon(entity: Entity, _body: CharacterBody3D) -> void:
	var weapon = entity.current_weapon as ZE_Weapon
	if weapon == null:
		return

	var weapon_component = weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
	var swing_node = weapon.get_node(weapon_component.swing_path) as PathFollow3D
	swing_node.progress_ratio = 0.0

	var tween = weapon.create_tween()
	tween.tween_property(swing_node, "progress_ratio", 1.0, weapon_component.swing_time)
	tween.tween_property(swing_node, "progress_ratio", 0.0, weapon_component.cooldown_time)


func spawn_projectile(entity: Entity, body: CharacterBody3D) -> void:
	var weapon = entity.current_weapon as ZE_Weapon
	if weapon == null:
		return

	var c_weapon = weapon.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
	var marker = weapon.get_node(c_weapon.muzzle_marker) as Marker3D
	if marker == null:
		printerr("Muzzle marker not found: ", c_weapon.muzzle_marker)
		return

	var new_projectile = c_weapon.projectile_scene.instantiate() as RigidBody3D
	body.get_parent().add_child(new_projectile)

	if new_projectile is Entity:
		ECS.world.add_entity(new_projectile)
	else:
		printerr("Projectile is not an entity: ", new_projectile)

	new_projectile.global_position = marker.global_position
	new_projectile.global_rotation = marker.global_rotation

	var forward = -marker.global_transform.basis.z.normalized()
	new_projectile.apply_impulse(forward * c_weapon.muzzle_velocity, marker.global_position)

	var sound_node = weapon.get_node(c_weapon.projectile_sound) as ZN_AudioSubtitle3D
	if sound_node == null:
		printerr("Weapon sound not found: ", c_weapon.projectile_sound)
		return

	var sound = ZC_Noise.from_node(sound_node)
	entity.add_component(sound)


func toggle_flashlight(_entity: Entity, body: CharacterBody3D) -> void:
	var light = body.get_node("./Head/Hands/Flashlight") as SpotLight3D
	if light != null:
		light.visible = not light.visible


func use_character(entity: Entity, player_entity: Entity) -> void:
	# turn to face player
	#if entity is ZE_Character:
	#	entity.look_at_target(player_entity.global_position)

	var node_3d := entity.get_node(".") as Node3D
	var forward = player_entity.global_position - node_3d.global_position
	forward.y = 0
	var look_basis = Basis.looking_at(forward, Vector3.UP, true)
	var look_transform = Transform3D(look_basis, node_3d.position)

	var tween := node_3d.create_tween()
	tween.tween_property(node_3d, "transform", look_transform, 1.0)

	# start dialogue
	var dialogue = entity.get_component(ZC_Dialogue)
	DialogueManager.show_dialogue_balloon(dialogue.dialogue_tree, dialogue.start_title, [
		{
			"dialogue" = dialogue,
			"entity" = entity,
		}
	])


func use_door(entity: Entity, player: ZC_Player) -> void:
	var door = entity.get_component(ZC_Door) as ZC_Door
	if door.is_locked:
		if player.has_key(door.key_name):
			door.is_locked = false
			%Hud.push_action("Used key: %s" % door.key_name)
		else:
			%Hud.push_action("Need key: %s" % door.key_name)

	if door.open_on_use and not door.is_locked:
		door.is_open = !door.is_open
		print("Door is open: ", door)


func use_food(entity: Entity, player_entity: Entity) -> void:
	var food = entity.get_component(ZC_Food) as ZC_Food
	var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
	var sound_node = entity.get_node(interactive.pickup_sound) as ZN_AudioSubtitle3D
	if sound_node != null:
		sound_node = sound_node.duplicate() # TODO: make sure this works correctly
		player_entity.add_child(sound_node)
		sound_node.play_subtitle()
		%Hud.push_action(sound_node.subtitle_tag)

	var health = player_entity.get_component(ZC_Health) as ZC_Health
	health.current_health = min(health.max_health, health.current_health + food.health)
	%Hud.push_action("Used food: %s" % interactive.name)

	remove_entity(entity)


func use_key(entity: Entity, player: ZC_Player) -> void:
	var key = entity.get_component(ZC_Key)
	player.add_key(key.name)
	%Hud.push_action("Picked up key: %s" % key.name)

	remove_entity(entity)


func use_objective(entity: Entity, _player: ZC_Player) -> void:
	var objective = entity.get_component(ZC_Objective) as ZC_Objective
	if objective.is_active and objective.complete_on_interaction:
		objective.is_complete = true
		print("Completed objective: ", objective.key)


func use_portal(entity: Entity, _player_entity: Entity) -> void:
	var portal = entity.get_component(ZC_Portal) as ZC_Portal
	if portal.is_open:
		portal.is_active = true
		print("Activated portal: ", portal)


func use_weapon(entity: Entity, player_entity: Entity) -> void:
	var weapon = entity as ZE_Weapon
	if weapon == null:
		return

	# remove target shimmer
	for shimmer_key in last_shimmer.keys():
		var shimmer_node = last_shimmer[shimmer_key]
		if weapon == shimmer_node:
			last_shimmer.erase(shimmer_key)
			weapon.remove_component(ZC_Shimmer)

	# reparent weapon to player
	var weapon_body = weapon.get_node(".") as RigidBody3D
	weapon_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	weapon_body.freeze = true
	weapon_body.linear_velocity = Vector3.ZERO
	weapon_body.angular_velocity = Vector3.ZERO
	weapon_body.transform = Transform3D.IDENTITY

	var interactive = weapon.get_component(ZC_Interactive) as ZC_Interactive
	%Hud.push_action("Picked up weapon: %s" % interactive.name)

	var player = player_entity as ZE_Player
	player.add_relationship(RelationshipUtils.make_holding(weapon))
	switch_weapon(player, weapon)


func remove_entity(entity: Entity) -> void:
	for shimmer_key in last_shimmer.keys():
		var shimmer_node = last_shimmer[shimmer_key]
		if entity == shimmer_node:
			last_shimmer.erase(shimmer_key)

	EntityUtils.remove(entity)


func remove_shimmer(entity: Entity) -> void:
	if entity in last_shimmer:
		var last_target = last_shimmer.get(entity)
		last_shimmer.erase(entity)

		if last_target == null:
			printerr("Removing shimmer from null entity: ", entity, last_target)
		else:
			last_target.remove_component(ZC_Shimmer)


## Equip the next weapon (always the first weapon in the player's inventory)
func equip_next_weapon(entity: ZE_Player) -> void:
	var inventory = entity.get_inventory()
	if inventory.size() == 0:
		return

	var next_weapon = inventory[0] as ZE_Weapon
	switch_weapon(entity, next_weapon)


func equip_previous_weapon(entity: ZE_Player) -> void:
	var inventory = entity.get_inventory()
	if inventory.size() == 0:
		return

	var previous_index = inventory.size() - 1
	var previous_weapon = inventory[previous_index] as ZE_Weapon
	switch_weapon(entity, previous_weapon)


func switch_weapon(entity: ZE_Player, new_weapon: ZE_Weapon) -> void:
	if entity.current_weapon != null:
		var weapon = entity.current_weapon
		weapon.get_parent().remove_child(weapon)
		entity.inventory_node.add_child(weapon)
		entity.remove_relationship(RelationshipUtils.make_equipped(weapon))

	entity.current_weapon = new_weapon
	new_weapon.get_parent().remove_child(new_weapon)
	entity.hands_node.add_child(new_weapon)
	entity.add_relationship(RelationshipUtils.make_equipped(new_weapon))

	var c_interactive = new_weapon.get_component(ZC_Interactive) as ZC_Interactive
	%Hud.set_weapon_label(c_interactive.name)
	%Hud.push_action("Switched to weapon: %s" % c_interactive.name)


func release_weapon(entity: Entity) -> void:
	var weapon = entity.current_weapon
	if weapon == null:
		return

	entity.current_weapon = null

	var weapon_position = weapon.global_position
	weapon.get_parent().remove_child(weapon)
	entity.get_parent().add_child(weapon)
	entity.remove_relationship(RelationshipUtils.make_equipped(weapon))
	entity.remove_relationship(RelationshipUtils.make_holding(weapon))

	var weapon_body = weapon.get_node(".") as RigidBody3D
	weapon_body.freeze = false
	weapon_body.global_position = weapon_position
