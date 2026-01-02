class_name ZS_PlayerSystem
extends System

@export var shimmer_offset: float = 4.0

var last_shimmer: Dictionary[Entity, Entity] = {} # dict for multiplayer


func get_raycast_end_point(raycast: RayCast3D) -> Vector3:
	return raycast.global_transform * raycast.target_position


func do_adaptive_aim(raycast: RayCast3D, entity: Entity, delta: float) -> void:
	var collision_point: Vector3 = Vector3.ZERO
	if raycast.is_colliding():
		# adjust the weapon marker to face the point of the collision
		collision_point = raycast.get_collision_point()
	else:
		collision_point = get_raycast_end_point(raycast)

	var weapon_marker = entity.weapon_node as Node3D
	if OptionsManager.options.gameplay.adaptive_aim == 1.0:
		weapon_marker.look_at(collision_point, Vector3.UP)
	elif OptionsManager.options.gameplay.adaptive_aim > 0.0:
		# From https://docs.godotengine.org/en/latest/tutorials/3d/using_transforms.html#interpolating-with-quaternions
		var collision_transform = weapon_marker.global_transform.looking_at(collision_point, Vector3.UP)
		var collision_quaternion = collision_transform.basis.get_rotation_quaternion()
		var current_quaternion = weapon_marker.global_transform.basis.get_rotation_quaternion()
		var slerped_quaternion = current_quaternion.slerp(collision_quaternion, OptionsManager.options.gameplay.adaptive_aim * delta)
		weapon_marker.global_transform.basis = Basis(slerped_quaternion)


func query():
	return q.with_all([ZC_Velocity, ZC_Player, ZC_Input])


func process(entities: Array[Entity], _components: Array, delta: float):
	for entity in entities:
		var velocity = entity.get_component(ZC_Velocity) as ZC_Velocity
		var player = entity.get_component(ZC_Player) as ZC_Player
		var input = entity.get_component(ZC_Input) as ZC_Input
		var stamina := entity.get_component(ZC_Stamina) as ZC_Stamina

		var body := entity.get_node(".") as CharacterBody3D
		body.rotation.x += input.turn_direction.x
		body.rotation.y += input.turn_direction.y
		body.rotation.z = input.turn_direction.z # not additive

		var forward = -body.global_transform.basis.z.normalized()
		var right = body.global_transform.basis.x.normalized()

		var direction = (
				(right * input.move_direction.x) +
				(forward * input.move_direction.y)
		).normalized()
		var speed = input.walk_speed

		if input.move_sprint and stamina.can_sprint():
			speed *= input.sprint_multiplier
		elif input.move_crouch:
			speed *= input.crouch_multiplier
			# TODO: move camera down

		var horizontal_velocity = direction * speed

		# Apply horizontal velocity, retain vertical velocity
		velocity.linear_velocity.x = horizontal_velocity.x
		velocity.linear_velocity.z = horizontal_velocity.z

		# Apply gravity
		var no_clip := OptionsManager.options.cheats.no_clip
		if no_clip:
			pass
		elif body.is_on_floor():
			pass
		else: # clipping and off the floor
			velocity.linear_velocity += velocity.gravity * delta

			# a basic approximation of terminal velocity
			if velocity.linear_velocity.y < 0:
				velocity.linear_velocity.y = max(velocity.gravity.y, velocity.linear_velocity.y)

		# Apply jump
		if input.move_jump and stamina.can_jump():
			if body.is_on_floor():
				stamina.current_stamina -= stamina.jump_cost
				velocity.linear_velocity.y = input.jump_speed

		# TODO: move this into the MovementSystem
		# Sync to CharacterBody3D (Node assumed attached to entity)
		var speed_multiplier := EntityUtils.get_speed_multiplier(entity)
		body.velocity = velocity.linear_velocity * speed_multiplier
		body.move_and_slide()
		_handle_collisions(body, delta)

		# Move weapon to follow hands
		if entity.current_weapon != null:
			var weapon_body = entity.current_weapon.get_node(".") as RigidBody3D
			weapon_body.global_transform = entity.weapon_node.global_transform

		# Process any effect relationships
		var effect_strength := EntityUtils.get_screen_effects(entity)
		for effect in effect_strength:
			if effect == null:
				continue

			%Menu.set_effect_strength(effect, effect_strength[effect], delta * 8)

		# Process any heard relationships
		var heard_noises := entity.get_relationships(RelationshipUtils.any_heard) as Array[Relationship]
		for rel in heard_noises:
			var noise := rel.target as ZC_Noise
			if noise.subtitle_tag == "":
				continue

			if OptionsManager.options.audio.subtitles:
				%Menu.push_action(noise.subtitle_tag)

		entity.remove_relationships(heard_noises)

		# Process any usage relationships
		var used_items := entity.get_relationships(RelationshipUtils.any_used) as Array[Relationship]
		for rel in used_items:
			InteractionUtils.interact(rel.target, entity, %Menu)
		entity.remove_relationships(used_items)

		# Pause menu
		if input.menu_pause:
			%Menu.toggle_pause()

		# Weapon switching
		if input.weapon_next:
			equip_next_weapon(entity as ZE_Player)
		elif input.weapon_previous:
			equip_previous_weapon(entity as ZE_Player)

		# Attack with weapon
		if input.use_attack:
			if entity.current_weapon != null:
				# Weapons can have both types
				if EntityUtils.is_melee_weapon(entity.current_weapon):
					swing_weapon(entity, body)
				if EntityUtils.is_ranged_weapon(entity.current_weapon):
					spawn_projectile(entity, body)

		# Holster weapon
		if input.use_holster:
			EntityUtils.switch_weapon(entity, null, %Menu)

		# Reloading weapon
		if input.use_reload:
			EntityUtils.reload_weapon(entity)
			_update_ammo_label(entity)

		# Toggle flashlight
		if input.use_light:
			toggle_flashlight(entity, body)

		var ray = entity.get_node(player.view_ray) as RayCast3D

		# Adjust the aim based on the ray's collision point or end point if there is no collision
		do_adaptive_aim(ray, entity, delta)

		var equipped := entity.get_relationships(RelationshipUtils.any_equipped)
		for rel in equipped:
			var item = rel.target
			if is_instance_valid(item) and item is Node3D:
				var parent := item.get_parent() as Node3D
				item.global_transform = parent.global_transform

		# Highlight interactive items
		var clear_collider := true
		if ray.is_colliding():
			var collider = ray.get_collider()
			var collider_entity := CollisionUtils.get_collider_entity(collider)

			# Use interactive items
			if EntityUtils.is_interactive(collider_entity):
				var interactive = collider_entity.get_component(ZC_Interactive) as ZC_Interactive
				# Check the interactive distance
				if interactive.shimmer_on_target and interactive.shimmer_range > 0.0:
					var distance := body.global_position.distance_to(ray.get_collision_point())
					if distance <= interactive.shimmer_range:
						if collider_entity != last_shimmer.get(entity) and collider_entity != entity.current_weapon:
							%Menu.clear_target_label()
							%Menu.reset_crosshair_color()
							remove_shimmer_key(entity)

						if collider_entity and collider_entity != entity.current_weapon:
							clear_collider = false
							%Menu.set_target_label(interactive.name)

							if not EntityUtils.has_shimmer(collider_entity):
								var shimmer = ZC_Shimmer.from_interactive(interactive)
								collider_entity.add_component(shimmer)
								last_shimmer[entity] = collider_entity

								var shimmer_start := (Time.get_ticks_msec() / 1000.0) + shimmer_offset
								RenderingServer.global_shader_parameter_set("shimmer_time", shimmer_start)

							if input.use_pickup:
								InteractionUtils.pickup(entity, collider_entity, %Menu)

							if input.use_interact:
								InteractionUtils.interact(entity, collider_entity, %Menu)

		if clear_collider:
			%Menu.clear_target_label()
			%Menu.reset_crosshair_color()
			remove_shimmer_key(entity)


func _update_ammo_label(player: Entity) -> void:
	if player is not ZE_Character:
		return

	var player_ammo := player.get_component(ZC_Ammo) as ZC_Ammo
	var player_weapon := player.current_weapon as ZE_Weapon
	if player_weapon == null:
		%Menu.set_ammo_label("")
		return

	var melee_weapon := player_weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
	if melee_weapon != null:
		var weapon_durability := player_weapon.get_component(ZC_Durability) as ZC_Durability
		%Menu.set_ammo_label("Durability: %d/%d" % [
			weapon_durability.current_durability,
			weapon_durability.max_durability,
		])

	var ranged_weapon := EntityUtils.get_ranged_component(player_weapon)
	if ranged_weapon != null:
		var weapon_ammo := player_weapon.get_component(ZC_Ammo) as ZC_Ammo
		var player_count := player_ammo.get_ammo(ranged_weapon.ammo_type)
		var weapon_count := weapon_ammo.get_ammo(ranged_weapon.ammo_type)
		var weapon_max := weapon_ammo.get_max_ammo(ranged_weapon.ammo_type)
		%Menu.set_ammo_label("%s: %d/%d + %d" % [
			ranged_weapon.ammo_type,
			weapon_count,
			weapon_max,
			player_count,
		])


func _handle_collisions(body: CharacterBody3D, delta: float) -> void:
	for collision_index in body.get_slide_collision_count():
		var collision: KinematicCollision3D = body.get_slide_collision(collision_index)
		var collider: Node3D = collision.get_collider()
		var position: Vector3 = collision.get_position()

		if collider is RigidBody3D:
			var push_direction := -collision.get_normal()
			var push_position = position - collider.global_position
			collider.apply_impulse(push_direction * 50 * delta, push_position)


func _set_damage_areas(entity: Entity, weapon: ZC_Weapon_Melee, enable: bool) -> void:
	print("Setting damage areas to ", enable, " for entity: ", entity)
	for area_path in weapon.damage_areas:
		var area = entity.get_node(area_path) as Area3D
		if "active" in area:
			area.active = enable
		if "monitoring" in area:
			area.monitoring = enable


func swing_weapon(entity: Entity, _body: CharacterBody3D) -> void:
	var weapon = entity.current_weapon as ZE_Weapon
	if weapon == null:
		return

	var c_weapon = weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
	var stamina := entity.get_component(ZC_Stamina) as ZC_Stamina
	if stamina.current_stamina < c_weapon.swing_stamina:
		return

	stamina.current_stamina -= c_weapon.swing_stamina

	var broken := EntityUtils.is_broken(weapon)
	if broken:
		weapon.apply_effects(ZR_Weapon_Effect.EffectType.MELEE_BREAK)

	var swing_node = entity.swing_path_follower as PathFollow3D
	swing_node.progress_ratio = 0.0

	var tween = weapon.create_tween()
	if not broken:
		tween.tween_callback(_set_damage_areas.bind(weapon, c_weapon, true))
	tween.tween_property(swing_node, "progress_ratio", 1.0, c_weapon.swing_time)
	tween.tween_property(swing_node, "progress_ratio", 0.0, c_weapon.cooldown_time)
	if not broken:
		tween.tween_callback(_set_damage_areas.bind(weapon, c_weapon, false))
		tween.tween_callback(_update_ammo_label.bind(entity))


func spawn_projectile(entity: Entity, body: CharacterBody3D) -> void:
	var weapon = entity.current_weapon as ZE_Weapon
	if weapon == null:
		return

	var weapon_ammo := weapon.get_component(ZC_Ammo) as ZC_Ammo
	var ranged_weapon = EntityUtils.get_ranged_component(weapon)
	var current_ammo := weapon_ammo.get_ammo(ranged_weapon.ammo_type)
	if current_ammo <= 0:
		weapon.apply_effects(ZR_Weapon_Effect.EffectType.RANGED_EMPTY)
		return

	weapon_ammo.remove_ammo(ranged_weapon.ammo_type, ranged_weapon.per_shot)
	_update_ammo_label(entity)

	var marker = weapon.get_node(ranged_weapon.muzzle_marker) as Marker3D
	if marker == null:
		printerr("Muzzle marker not found: ", ranged_weapon.muzzle_marker)
		return

	var new_projectile = ranged_weapon.projectile_scene.instantiate() as RigidBody3D
	body.get_parent().add_child(new_projectile)

	if new_projectile is Entity:
		ECS.world.add_entity(new_projectile)
		new_projectile.add_relationship(RelationshipUtils.make_fired(entity))
	else:
		printerr("Projectile is not an entity: ", new_projectile)

	new_projectile.global_position = marker.global_position
	new_projectile.global_rotation = marker.global_rotation

	var forward = -marker.global_transform.basis.z.normalized()
	new_projectile.apply_impulse(forward * ranged_weapon.muzzle_velocity, marker.global_position)

	weapon.apply_effects(ZR_Weapon_Effect.EffectType.RANGED_FIRE)

	# tween along recoil path
	if ranged_weapon.recoil_path:
		var recoil_path := ranged_weapon.recoil_path as PathFollow3D
		var recoil_tween := weapon.create_tween()
		recoil_tween.tween_property(recoil_path, "progress_ratio", ranged_weapon.recoil_per_shot, ranged_weapon.recoil_time)
		recoil_tween.tween_property(recoil_path, "progress_ratio", 0.0, ranged_weapon.recoil_time)

	# unequip thrown weapons when they are out of ammo
	# TODO: add an option to disable this in the menu
	if ranged_weapon is ZC_Weapon_Thrown and weapon_ammo.is_all_empty():
		EntityUtils.switch_weapon(entity, null, %Menu)


func toggle_flashlight(_entity: Entity, body: CharacterBody3D) -> void:
	# TODO: type this node or use a component
	var light = body.get_node("./Head/Hands/Flashlight")
	if light != null:
		light.enabled = not light.enabled


func remove_shimmer_key(entity: Entity) -> void:
	if entity in last_shimmer:
		var last_target = last_shimmer.get(entity)
		last_shimmer.erase(entity)

		if last_target == null:
			printerr("Removing shimmer from null entity: ", entity, last_target)
		else:
			last_target.remove_component(ZC_Shimmer)


func remove_shimmer_target(entity: Entity) -> void:
	for shimmer_key in last_shimmer.keys():
		var shimmer_node = last_shimmer[shimmer_key]
		if entity == shimmer_node:
			last_shimmer.erase(shimmer_key)

			if entity != null:
				entity.remove_component(ZC_Shimmer)


# TODO: move to EntityUtils
func _list_player_weapons(entity: ZE_Player) -> Array[ZE_Weapon]:
	var inventory = entity.get_inventory()
	var weapons: Array[ZE_Weapon] = []
	for item in inventory:
		if EntityUtils.is_weapon(item):
			weapons.append(item)

	return weapons


## Equip the next weapon (always the first weapon in the player's inventory)
func equip_next_weapon(entity: ZE_Player) -> void:
	var weapons := _list_player_weapons(entity)
	if weapons.size() == 0:
		return

	var next_weapon = weapons[0]
	EntityUtils.switch_weapon(entity, next_weapon, %Menu)


func equip_previous_weapon(entity: ZE_Player) -> void:
	var weapons := _list_player_weapons(entity)
	if weapons.size() == 0:
		return

	var previous_index = weapons.size() - 1
	var previous_weapon = weapons[previous_index] as ZE_Weapon
	EntityUtils.switch_weapon(entity, previous_weapon, %Menu)
