class_name ZS_PlayerSystem
extends System

@export var shimmer_offset: float = 4.0
## The amount of time (in seconds) after leaving a surface during which the player can still jump.
@export var coyote_time: float = 0.1


# TODO: move to ray utils
func get_raycast_end_point(raycast: RayCast3D) -> Vector3:
	return raycast.global_transform * raycast.target_position


func _apply_adaptive_aim(raycast: RayCast3D, entity: Entity, delta: float, min_ratio: float = 0.25) -> void:
	var aim_point: Vector3 = Vector3.ZERO
	var end_point := get_raycast_end_point(raycast)

	if raycast.is_colliding():
		# adjust the weapon marker to face the point of the collision
		aim_point = raycast.get_collision_point()
	else:
		aim_point = end_point

	# make sure the aim point is not too close to the player to avoid weird aiming issues
	var min_point := raycast.global_transform.origin.lerp(end_point, min_ratio)
	if aim_point.distance_squared_to(raycast.global_transform.origin) < min_point.distance_squared_to(raycast.global_transform.origin):
		aim_point = min_point

	for node: Node3D in entity.aim_nodes:
		if OptionsManager.options.gameplay.adaptive_aim == 1.0:
			node.look_at(aim_point, Vector3.UP)
		elif OptionsManager.options.gameplay.adaptive_aim > 0.0:
			# From https://docs.godotengine.org/en/latest/tutorials/3d/using_transforms.html#interpolating-with-quaternions
			var collision_transform = node.global_transform.looking_at(aim_point, Vector3.UP)
			var collision_quaternion = collision_transform.basis.get_rotation_quaternion()
			var current_quaternion = node.global_transform.basis.get_rotation_quaternion()
			var slerped_quaternion = current_quaternion.slerp(collision_quaternion, OptionsManager.options.gameplay.adaptive_aim * delta)
			node.global_transform.basis = Basis(slerped_quaternion)


func _draw_debug_ray(raycast: RayCast3D) -> void:
	if OptionsManager.options.cheats.show_ray_casts == false:
		return

	var from := raycast.global_transform.origin
	var to := get_raycast_end_point(raycast)
	var hit := raycast.is_colliding()
	var hit_point := Vector3.ZERO
	if hit:
		hit_point = raycast.get_collision_point()

	DebugDraw3D.draw_line_hit(from, to, hit_point, hit, 0.25, Color.RED, Color.GREEN, OptionsManager.options.cheats.debug_duration / 100.0)


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

		# Disable ladder movement when at the bottom (on floor) and trying to move down
		var use_ladder_movement: bool = body.is_on_ladder and not (body.is_on_floor and input.move_direction.y < 0)

		var direction: Vector3
		if use_ladder_movement:
			# On ladder: forward/back input moves vertically, strafe still works horizontally
			direction = (
					(right * input.move_direction.x) +
					(Vector3.UP * input.move_direction.y)
			).normalized()
		else:
			direction = (
					(right * input.move_direction.x) +
					(forward * input.move_direction.y)
			).normalized()
		var speed = input.walk_speed

		if input.move_sprint and stamina.can_sprint():
			speed *= input.sprint_multiplier
		elif input.move_crouch:
			speed *= input.crouch_multiplier
			# TODO: move camera down

		var movement_velocity = direction * speed

		if use_ladder_movement:
			# On ladder: apply full 3D velocity
			velocity.linear_velocity = movement_velocity
		else:
			# Apply horizontal velocity, retain vertical velocity
			velocity.linear_velocity.x = movement_velocity.x
			velocity.linear_velocity.z = movement_velocity.z

		_apply_gravity(velocity, body as Node, delta) # TODO: dirty dirty hack
		_apply_jump(velocity, input, stamina, body as Node) # TODO: dirty hack

		# TODO: move this into the MovementSystem
		# Sync to CharacterBody3D (Node assumed attached to entity)
		var speed_multiplier := EntityUtils.get_speed_multiplier(entity)
		body.velocity = velocity.linear_velocity * speed_multiplier
		body.ikcc_move_and_slide()

		_process_screen_effects(entity, delta)
		_process_heard_noises(entity)
		_process_used_items(entity)

		# Pause menu
		if input.menu_pause:
			%Menu.toggle_pause()

		# Weapon switching
		if input.weapon_next:
			equip_next_weapon(entity as ZE_Player)
		elif input.weapon_previous:
			equip_previous_weapon(entity as ZE_Player)

		# Attack with weapon
		if input.attack_starting:
			_handle_weapon_attack(entity)

		# Holster weapon
		if input.use_holster:
			EntityUtils.switch_weapon(entity, null, %Menu)

		# Item shortcuts
		if input.any_shortcut:
			_handle_item_shortcuts(entity, input)

		# Reloading weapon
		if input.use_reload:
			EntityUtils.reload_weapon(entity)
			_update_ammo_label(entity)

		# Toggle flashlight
		if input.use_light:
			toggle_flashlight(entity, body)

		# Adjust the aim based on the ray's collision point or end point if there is no collision
		var ray = entity.get_node(player.view_ray) as RayCast3D
		_draw_debug_ray(ray)

		_apply_adaptive_aim(ray, entity, delta)

		# Handle interactions
		_handle_interactive(entity, input, body, ray)

		# Finally, update equipped items' transforms after any movement, equip/unequip, etc.
		_update_equipped_items(entity)

	# Clean up invalid shimmer references
	for entity in entities:
		var player = entity as ZE_Player
		if player.last_shimmer_target:
			# TODO: SHIMMER - needs to check if the shimmer component is enabled, not whether it exists
			if not is_instance_valid(player.last_shimmer_target) or not player.last_shimmer_target.has_component(ZC_Shimmer):
				player.last_shimmer_target = null


func _apply_gravity(velocity: ZC_Velocity, body: ZE_Player_IKCC, delta: float) -> void:
	if OptionsManager.options.cheats.no_clip:
		pass
	elif body.is_on_floor:
		pass
	elif body.is_on_ladder:
		pass
	else: # clipping and off the floor
		velocity.linear_velocity += velocity.gravity * delta

		# a basic approximation of terminal velocity
		if velocity.linear_velocity.y < 0:
			velocity.linear_velocity.y = max(velocity.gravity.y, velocity.linear_velocity.y)


func _apply_jump(velocity: ZC_Velocity, input: ZC_Input, stamina: ZC_Stamina, body: ZE_Player_IKCC) -> void:
	if input.move_jump and stamina.can_jump():
		# Allow jumping if on floor or within coyote time window
		if body.is_on_floor or body.time_since_on_floor <= input.coyote_time:
			stamina.current_stamina -= stamina.jump_cost
			velocity.linear_velocity.y = input.jump_speed


func _process_screen_effects(entity: Entity, delta: float) -> void:
	var effect_strength := EntityUtils.get_screen_effects(entity)
	for effect in effect_strength:
		if effect == null:
			continue

		%Menu.set_effect_strength(effect, effect_strength[effect], delta * 8) # TODO: magic number


func _process_heard_noises(entity: Entity) -> void:
	var heard_noises := entity.get_relationships(RelationshipUtils.any_heard) as Array[Relationship]
	for rel in heard_noises:
		var noise := rel.target as ZC_Noise
		if noise.subtitle_tag == "":
			continue

		if OptionsManager.options.audio.subtitles:
			# %Menu.push_action(noise.subtitle_tag)
			%Menu.append_message(ZC_Message.make_subtitle(noise.subtitle_tag))

	entity.remove_relationships(heard_noises)


func _process_used_items(entity: Entity) -> void:
	var used_items := entity.get_relationships(RelationshipUtils.any_used) as Array[Relationship]
	for rel in used_items:
		InteractionUtils.interact(entity, rel.target, %Menu)
	entity.remove_relationships(used_items)


func _handle_weapon_attack(entity: Entity) -> void:
	var weapons := RelationshipUtils.get_wielding(entity)
	for weapon in weapons:
		# Weapons can have both types
		if EntityUtils.is_melee_weapon(weapon):
			swing_weapon(entity, weapon)
		if EntityUtils.is_ranged_weapon(weapon):
			spawn_projectile(entity, weapon)


func _handle_item_shortcuts(entity: Entity, input: ZC_Input) -> void:
	var pressed_shortcut: ZC_ItemShortcut.ItemShortcut = ZC_ItemShortcut.ItemShortcut.SHORTCUT_1
	for shortcut in input.shortcuts.keys():
		if input.shortcuts[shortcut]:
			pressed_shortcut = shortcut
			break

	var inventory_node := EntityUtils.get_inventory_node(entity)
	var chosen_item = inventory_node.get_by_shortcut(pressed_shortcut) as ZE_Weapon
	if chosen_item == null:
		return

	if EntityUtils.is_weapon(chosen_item):
		EntityUtils.switch_weapon(entity, chosen_item, %Menu)
	else:
		assert(false, "TODO: handle non-weapon shortcuts")


func _update_equipped_items(entity: Entity) -> void:
	var equipped := entity.get_relationships(RelationshipUtils.any_equipped)
	for rel in equipped:
		var item = rel.target
		if is_instance_valid(item) and item is Node3D:
			var parent := item.get_parent() as Node3D
			item.global_transform = parent.global_transform


func _clear_collider(entity: Entity) -> void:
	%Menu.clear_target_label()
	%Menu.reset_crosshair_color()
	_clear_player_shimmer(entity as ZE_Player)


func _handle_interactive(entity: Entity, input: ZC_Input, body: CharacterBody3D, ray: RayCast3D) -> void:
	if not ray.is_colliding():
		_clear_collider(entity)
		return

	var collider = ray.get_collider()
	var collider_entity := CollisionUtils.get_collider_entity(collider)
	if collider_entity == null:
		_clear_collider(entity)
		return

	var player = entity as ZE_Player
	var equipment := RelationshipUtils.get_equipment(player)
	if collider_entity in equipment:
		_clear_collider(entity)
		return

	var distance := body.global_position.distance_to(ray.get_collision_point())

	# Enable shimmering items
	var shimmer := collider_entity.get_component(ZC_Shimmer) as ZC_Shimmer
	if shimmer != null:
		if shimmer.on_target and distance <= shimmer.distance:
			if collider_entity != player.last_shimmer_target:
				_clear_collider(player)

			if not shimmer.enabled:
				shimmer.enabled = true
				player.last_shimmer_target = collider_entity

				var shimmer_start := (Time.get_ticks_msec() / 1000.0) + shimmer_offset
				RenderingServer.global_shader_parameter_set("shimmer_time", shimmer_start)

	# Use interactive items
	var interactive := collider_entity.get_component(ZC_Interactive) as ZC_Interactive
	if interactive != null:
		if distance <= interactive.distance:
			%Menu.set_crosshair_color(interactive.crosshair_color)
			%Menu.set_target_label(interactive.name)

			if input.use_pickup:
				InteractionUtils.pickup(entity, collider_entity, %Menu)
				_clear_player_shimmer(entity as ZE_Player)
				_update_ammo_label(entity)

			if input.use_interact:
				InteractionUtils.interact(entity, collider_entity, %Menu)
				_clear_player_shimmer(entity as ZE_Player)
				_update_ammo_label(entity)


func _update_ammo_label(player: Entity) -> void:
	var player_ammo := player.get_component(ZC_Ammo) as ZC_Ammo
	if player_ammo == null:
		%Menu.set_ammo_label(null, null)
		return

	var weapons := RelationshipUtils.get_wielding(player)
	if weapons.size() == 0:
		%Menu.set_ammo_label(null, null)
		return

	var player_weapon := weapons[0] as ZE_Weapon
	if player_weapon == null:
		%Menu.set_ammo_label(null, null)
		return

	%Menu.set_ammo_label(player_weapon, player_ammo)


func _set_damage_areas(entity: Entity, weapon: ZC_Weapon_Melee, enable: bool) -> void:
	ZombieLogger.debug("Setting damage areas to {0} for entity: {1}", [enable, entity.get_path()])
	for area_path in weapon.damage_areas:
		var area = entity.get_node(area_path) as Area3D
		if "active" in area:
			area.active = enable
		if "monitoring" in area:
			area.monitoring = enable


# TODO: move to weapon utils or system
func swing_weapon(entity: Entity, weapon: ZE_Weapon) -> void:
	var c_weapon = weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
	var stamina := entity.get_component(ZC_Stamina) as ZC_Stamina
	if stamina.current_stamina < c_weapon.swing_stamina:
		return

	stamina.current_stamina -= c_weapon.swing_stamina

	var swing_node = entity.swing_path_follower as PathFollow3D
	swing_node.progress_ratio = 0.0

	var broken := EntityUtils.is_broken(weapon)
	if broken:
		weapon.apply_effects(ZR_Weapon_Effect.EffectType.MELEE_BREAK)
	else:
		weapon.apply_effects(ZR_Weapon_Effect.EffectType.MELEE_SWING)

	var tween = weapon.create_tween()
	if not broken:
		tween.tween_callback(_set_damage_areas.bind(weapon, c_weapon, true))
	tween.tween_property(swing_node, "progress_ratio", 1.0, c_weapon.swing_time)
	tween.tween_property(swing_node, "progress_ratio", 0.0, c_weapon.cooldown_time)
	if not broken:
		tween.tween_callback(_set_damage_areas.bind(weapon, c_weapon, false))
		tween.tween_callback(_update_ammo_label.bind(entity))


# TODO: move to weapon utils or system
func spawn_projectile(entity: Entity, weapon: ZE_Weapon) -> void:
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
		ZombieLogger.warning("Muzzle marker not found: {0}", [ranged_weapon.muzzle_marker])
		return

	var new_projectile = ranged_weapon.projectile_scene.instantiate() as RigidBody3D
	entity.get_parent().add_child(new_projectile)

	if new_projectile is Entity:
		ECS.world.add_entity(new_projectile)
		new_projectile.add_relationship(RelationshipUtils.make_fired(entity))
	else:
		ZombieLogger.warning("Projectile is not an entity: {0}", [new_projectile])

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


func toggle_flashlight(entity: Entity, _body: CharacterBody3D) -> void:
	var equipped := entity.get_relationships(RelationshipUtils.any_equipped)
	for rel in equipped:
		var item = rel.target
		if item is Entity:
			var light := item.get_component(ZC_Light) as ZC_Light
			if light != null:
				light.enabled = not light.enabled


func _clear_player_shimmer(player: ZE_Player) -> void:
	if not player.last_shimmer_target:
		return

	if not is_instance_valid(player.last_shimmer_target):
		return

	var shimmer := player.last_shimmer_target.get_component(ZC_Shimmer) as ZC_Shimmer
	if shimmer == null:
		return

	shimmer.enabled = false
	player.last_shimmer_target = null


func _get_current_index(entity: ZE_Player, weapons: Array, default: int = 0) -> int:
	var wielding := RelationshipUtils.get_wielding(entity)
	if wielding.size() == 0:
		return default

	var last_weapon := wielding[0]
	var last_index := weapons.find(last_weapon)
	if last_index == -1:
		return default

	return last_index


## Equip the next weapon
func equip_next_weapon(entity: ZE_Player) -> void:
	var weapons := RelationshipUtils.get_weapons(entity)
	if weapons.size() == 0:
		return

	var current_index := _get_current_index(entity, weapons)
	var next_index := current_index + 1
	if next_index >= weapons.size():
		next_index = 0

	# if you only have one weapon, do nothing
	if next_index == current_index:
		return

	var next_weapon := weapons[next_index] as ZE_Weapon
	EntityUtils.switch_weapon(entity, next_weapon, %Menu)
	_update_ammo_label(entity)


func equip_previous_weapon(entity: ZE_Player) -> void:
	var weapons := RelationshipUtils.get_weapons(entity)
	if weapons.size() == 0:
		return

	var current_index := _get_current_index(entity, weapons, -1)
	var previous_index := current_index - 1
	if previous_index < 0:
		previous_index = weapons.size() - 1

	# if you only have one weapon, do nothing
	if previous_index == current_index:
		return

	var previous_weapon := weapons[previous_index] as ZE_Weapon
	EntityUtils.switch_weapon(entity, previous_weapon, %Menu)
	_update_ammo_label(entity)
