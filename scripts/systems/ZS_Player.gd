class_name ZS_PlayerSystem
extends System

@export var shimmer_offset: float = 4.0

var last_shimmer: Dictionary[Entity, Entity] = {} # dict for multiplayer


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

		var horizontal_velocity = direction * speed

		# Apply horizontal velocity, retain vertical velocity
		velocity.linear_velocity.x = horizontal_velocity.x
		velocity.linear_velocity.z = horizontal_velocity.z

		# Apply gravity
		var no_clip := OptionsManager.options.cheats.no_clip
		if no_clip or body.is_on_floor():
			velocity.linear_velocity.y = 0
		else:
			velocity.linear_velocity += velocity.gravity * delta

			# TODO: fix infinite gravity
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

			%Menu.push_action(noise.subtitle_tag)
			entity.remove_relationship(rel)

		# Process any usage relationships
		var used_items := entity.get_relationships(RelationshipUtils.any_used) as Array[Relationship]
		for rel in used_items:
			use_interactive(rel.target, entity, player, false)
			entity.remove_relationship(rel)

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
			switch_weapon(entity, null)

		# Reloading weapon
		if input.use_reload:
			reload_weapon(entity)

		# Toggle flashlight
		if input.use_light:
			toggle_flashlight(entity, body)

		# Highlight interactive items
		var ray = entity.get_node(player.view_ray) as RayCast3D
		if ray.is_colliding():
			var collider = ray.get_collider()
			var collider_entity := CollisionUtils.get_collider_entity(collider)

			if collider_entity != last_shimmer.get(entity) and collider_entity != entity.current_weapon:
				%Menu.clear_target_label()
				%Menu.reset_crosshair_color()
				remove_shimmer_key(entity)

			# Use interactive items
			if collider_entity and collider_entity != entity.current_weapon:
				if EntityUtils.is_interactive(collider_entity):
					var interactive = collider_entity.get_component(ZC_Interactive) as ZC_Interactive
					%Menu.set_target_label(interactive.name)

					if not EntityUtils.has_shimmer(collider_entity):
						var shimmer = ZC_Shimmer.from_interactive(interactive)
						collider_entity.add_component(shimmer)
						last_shimmer[entity] = collider_entity

						var shimmer_start := (Time.get_ticks_msec() / 1000.0) + shimmer_offset
						RenderingServer.global_shader_parameter_set("shimmer_time", shimmer_start)

					if input.use_pickup:
						pickup_item(collider_entity, entity)

					if input.use_interact:
						use_interactive(collider_entity, entity, player)

		else:
			%Menu.clear_target_label()
			%Menu.reset_crosshair_color()
			remove_shimmer_key(entity)


func use_interactive(collider: Entity, entity: Entity, player: ZC_Player, set_crosshair: bool = true) -> void:
	# TODO: queue entities for removal but don't fully remove them until after all of the components have been processed
	if collider.has_component(ZC_Cooldown):
		return

	var interactive = collider.get_component(ZC_Interactive) as ZC_Interactive
	if EntityUtils.is_locked(collider):
		var locked := collider.get_component(ZC_Locked) as ZC_Locked
		if player.has_key(locked.key_name):
			locked.is_locked = false
			%Menu.push_action("Used %s key to unlock %s" % [locked.key_name, interactive.name])
		else:
			%Menu.push_action("Need %s key to use %s" % [locked.key_name, interactive.name])
			return

	collider.emit_action(Enums.ActionEvent.ENTITY_USE, entity)

	# add used-by relationship, replacing any existing ones
	RelationshipUtils.add_unique_relationship(collider, Relationship.new(ZC_Used.new(), entity))

	if collider.has_component(ZC_Dialogue):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.DODGER_BLUE)

		use_dialogue(collider, entity)

	if collider.has_component(ZC_Objective):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.GOLD)
		use_objective(collider, player)

	# Check for weapons to avoid unloading and removing weapons
	if collider.has_component(ZC_Ammo) and not EntityUtils.is_weapon(collider):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.GREEN)
		use_ammo(collider, entity)

	if collider.has_component(ZC_Effect_Armor):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.GREEN)
		use_armor(collider, entity)

	if collider.has_component(ZC_Button):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.GOLD)
		use_button(collider, entity)

	if collider.has_component(ZC_Food):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.GREEN)
		use_food(collider, entity)

	if collider.has_component(ZC_Key):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.YELLOW)
		use_key(collider, entity, player)

	if collider.has_component(ZC_Door):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.DODGER_BLUE)
		use_door(collider, entity)

	if collider.has_component(ZC_Portal):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.GOLD)
		use_portal(collider, entity)

	if EntityUtils.is_weapon(collider):
		if set_crosshair:
			%Menu.set_crosshair_color(Color.ORANGE)
		use_weapon(collider, entity)


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

	var ranged_weapon := player_weapon.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
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

	var swing_node = weapon.get_node(c_weapon.swing_path) as PathFollow3D
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
	var ranged_weapon = weapon.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
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


func toggle_flashlight(_entity: Entity, body: CharacterBody3D) -> void:
	var light = body.get_node("./Head/Hands/Flashlight") as SpotLight3D
	if light != null:
		light.visible = not light.visible


func _get_level_markers(root: Node = null) -> Dictionary[String, Marker3D]:
	var markers: Dictionary[String, Marker3D] = {}

	if root == null:
		root = %Level

	for child in root.get_children():
		if child is Marker3D:
			markers[child.name] = child
		elif child is Entity:
			continue # skip markers within entities
		else:
			# recurse into the world to find markers
			markers.merge(_get_level_markers(child))

	return markers


func _add_sound(sound: ZN_AudioSubtitle3D, player_entity: Entity) -> void:
	player_entity.add_child(sound)
	# sound.play_subtitle()


func pickup_item(entity: Entity, player_entity: Entity) -> void:
	var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
	if EntityUtils.is_locked(entity):
		var locked := entity.get_component(ZC_Locked) as ZC_Locked
		var c_player := player_entity.get_component(ZC_Player) as ZC_Player

		if c_player.has_key(locked.key_name):
			locked.is_locked = false
			%Menu.push_action("Used %s key to unlock %s" % [locked.key_name, interactive.name])
		else:
			%Menu.push_action("Need %s key to pick up %s" % [locked.key_name, interactive.name])
			return

	remove_shimmer_target(entity)

	entity.get_parent().remove_child(entity)
	entity.visible = false

	var player := player_entity as ZE_Player
	player.inventory_node.add_child(entity)

	%Menu.push_action("Picked up item: %s" % interactive.name)

	if interactive.pickup_sound:
		var sound := interactive.pickup_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, player_entity)


func use_ammo(entity: Entity, player_entity: Entity) -> void:
	var entity_ammo := entity.get_component(ZC_Ammo) as ZC_Ammo
	var player_ammo := player_entity.get_component(ZC_Ammo) as ZC_Ammo
	player_ammo.transfer(entity_ammo)
	_update_ammo_label(player_entity)

	var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
	%Menu.push_action("Picked up ammo: %s" % interactive.name)

	if interactive.pickup_sound:
		var sound := interactive.pickup_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, player_entity)

	if EntityUtils.is_ammo_empty(entity_ammo):
		remove_entity(entity)


func use_armor(entity: Entity, player_entity: Entity) -> void:
	var armor = entity as ZE_Armor
	if armor == null:
		return

	remove_shimmer_target(armor)

	var modifier := armor.get_component(ZC_Effect_Armor) as ZC_Effect_Armor
	var player = player_entity as ZE_Player
	player.add_relationship(RelationshipUtils.make_modifier_damage(modifier.multiplier))
	player.add_relationship(RelationshipUtils.make_wearing(armor))

	player.current_armor = entity

	entity.get_parent().remove_child(entity)
	player.inventory_node.add_child(entity)

	var interactive = armor.get_component(ZC_Interactive) as ZC_Interactive
	%Menu.push_action("Picked up armor: %s" % interactive.name)

	if interactive.use_sound:
		var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, player_entity)

	# TODO: should inventory items follow the player in 3D space?
	var entity3d := entity.get_node(".") as RigidBody3D
	entity3d.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	entity3d.freeze = true
	entity3d.visible = false

	for child in entity3d.get_children():
		if child is CollisionShape3D:
			child.disabled = true


func _format_button_pressed(pressed: bool) -> String:
	if pressed:
		return "on"
	else:
		return "off"


func use_button(entity: Entity, _player_entity: Entity) -> void:
	var button := entity.get_component(ZC_Button) as ZC_Button
	if not button.is_active:
		return

	# TODO: should add a pressed-by relationship that is used by the button observer
	if button.is_toggle:
		button.is_pressed = not button.is_pressed
		var pressed_message := _format_button_pressed(button.is_pressed)
		%Menu.push_action("Toggled button %s" % pressed_message)
	else:
		button.is_pressed = true
		%Menu.push_action("Pressed button")


func use_dialogue(entity: Entity, player_entity: Entity) -> void:
	# get level markers
	var markers := _get_level_markers()

	# start dialogue
	var helpers := DialogueUtils.DialogueHelper.new(entity, markers)
	var dialogue = entity.get_component(ZC_Dialogue)
	%Menu.start_dialogue(dialogue.dialogue_tree, dialogue.start_title, [
		{
			"dialogue" = dialogue,
			"helpers" = helpers,
			"markers" = markers,
			"player" = player_entity,
			"speaker" = entity,
		}
	])


func use_door(entity: Entity, _player_entity: Entity) -> void:
	var door := entity.get_component(ZC_Door) as ZC_Door

	if door.open_on_use and not EntityUtils.is_locked(entity):
		door.is_open = !door.is_open
		print("Door is open: ", door)

		var interactive := entity.get_component(ZC_Interactive) as ZC_Interactive
		if interactive.use_sound:
			var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
			_add_sound(sound, entity)


func use_food(entity: Entity, player_entity: Entity) -> void:
	var health = player_entity.get_component(ZC_Health) as ZC_Health
	if health.current_health >= health.max_health:
		pickup_item(entity, player_entity)
		return

	var food = entity.get_component(ZC_Food) as ZC_Food
	health.current_health += food.health

	var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
	%Menu.push_action("Used food: %s" % interactive.name)

	if interactive.use_sound:
		var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, player_entity)

	remove_entity(entity)


func use_key(entity: Entity, player_entity: Entity, player: ZC_Player) -> void:
	var key = entity.get_component(ZC_Key)
	player.add_key(key.name)
	%Menu.push_action("Found key: %s" % key.name)

	var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
	if interactive.pickup_sound:
		var sound := interactive.pickup_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, player_entity)

	remove_entity(entity)


func use_objective(entity: Entity, _player: ZC_Player) -> void:
	var objective = entity.get_component(ZC_Objective) as ZC_Objective
	if objective.is_active and objective.complete_on_interaction:
		objective.is_complete = true
		print("Completed objective: ", objective.key)

		var interactive := entity.get_component(ZC_Interactive) as ZC_Interactive
		if interactive.use_sound:
			var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
			_add_sound(sound, entity)


func use_portal(entity: Entity, _player_entity: Entity) -> void:
	var portal = entity.get_component(ZC_Portal) as ZC_Portal
	if portal.is_open:
		portal.is_active = true
		print("Activated portal: ", portal)

		var interactive := entity.get_component(ZC_Interactive) as ZC_Interactive
		if interactive.use_sound:
			var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
			_add_sound(sound, entity)


func use_weapon(entity: Entity, player_entity: Entity) -> void:
	var weapon = entity as ZE_Weapon
	if weapon == null:
		return

	remove_shimmer_target(weapon)

	# reparent weapon to player
	var weapon_body = weapon.get_node(".") as RigidBody3D
	weapon_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	weapon_body.freeze = true
	weapon_body.linear_velocity = Vector3.ZERO
	weapon_body.angular_velocity = Vector3.ZERO
	weapon_body.transform = Transform3D.IDENTITY

	var player = player_entity as ZE_Player
	player.add_relationship(RelationshipUtils.make_holding(weapon))
	switch_weapon(player, weapon)

	var interactive = weapon.get_component(ZC_Interactive) as ZC_Interactive
	%Menu.push_action("Found new weapon: %s" % interactive.name)

	#if interactive.use_sound:
	#	var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
	#	_add_sound(sound, entity)


func remove_entity(entity: Entity) -> void:
	remove_shimmer_target(entity)
	EntityUtils.keep_sounds(entity)
	EntityUtils.remove(entity)


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
	switch_weapon(entity, next_weapon)


func equip_previous_weapon(entity: ZE_Player) -> void:
	var weapons := _list_player_weapons(entity)
	if weapons.size() == 0:
		return

	var previous_index = weapons.size() - 1
	var previous_weapon = weapons[previous_index] as ZE_Weapon
	switch_weapon(entity, previous_weapon)


func switch_weapon(entity: ZE_Player, new_weapon: ZE_Weapon) -> void:
	var old_weapon = EntityUtils.equip_weapon(entity, new_weapon)

	if new_weapon == null:
		%Menu.clear_weapon_label()
		%Menu.clear_ammo_label()

		if old_weapon != null:
			var old_interactive := old_weapon.get_component(ZC_Interactive) as ZC_Interactive
			%Menu.push_action("Holstered weapon: %s" % old_interactive.name)

		return

	new_weapon.emit_action(Enums.ActionEvent.ENTITY_EQUIP, entity)

	var c_interactive = new_weapon.get_component(ZC_Interactive) as ZC_Interactive
	%Menu.set_weapon_label(c_interactive.name)
	_update_ammo_label(entity)
	%Menu.push_action("Switched to weapon: %s" % c_interactive.name)

	if c_interactive.use_sound:
		var sound := c_interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, entity)


func reload_weapon(player: Entity) -> void:
	if player is not ZE_Character:
		return

	var current_weapon := player.current_weapon as ZE_Weapon
	var weapon_ammo := current_weapon.get_component(ZC_Ammo) as ZC_Ammo
	if weapon_ammo == null:
		return

	var ranged_weapon := current_weapon.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
	if ranged_weapon == null:
		return

	var player_ammo := player.get_component(ZC_Ammo) as ZC_Ammo
	if player_ammo.get_ammo(ranged_weapon.ammo_type) == 0:
		return

	weapon_ammo.transfer(player_ammo)
	current_weapon.apply_effects(ZR_Weapon_Effect.EffectType.RANGED_RELOAD)
	_update_ammo_label(player)
