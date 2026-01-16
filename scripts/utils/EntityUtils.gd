class_name EntityUtils


static func is_valid_entity(entity: Node) -> bool:
	if not is_instance_valid(entity):
		return false

	if entity is not Entity:
		return false

	return true


static func apply_damage(actor: Entity, target: Node, base_damage: int, multiplier: float = 1.0) -> int:
	if target is not Entity:
		return 0

	if not EntityUtils.has_health(target):
		return 0

	var damage := floori(base_damage * multiplier)
	target.add_relationship(RelationshipUtils.make_damage(actor, damage))
	return damage


static func get_drop_transform(character: ZE_Character) -> Transform3D:
	var character3d := character.get_node(".") as Node3D
	var forward := -character3d.global_transform.basis.z
	var up := character3d.global_transform.basis.y
	var drop_offset := forward * 1.0 + up * 0.5
	var fallback_position := character3d.global_transform.translated(drop_offset)

	var inventory_component := character.get_component(ZC_Inventory) as ZC_Inventory
	if inventory_component == null:
		return fallback_position

	var drop_marker_node := character.get_node_or_null(inventory_component.drop_marker) as Node3D
	if drop_marker_node == null:
		return fallback_position

	return drop_marker_node.global_transform


# TODO: to inventory utils
static func drop_item(character: ZE_Character, item: ZE_Base) -> ZE_Weapon:
	var item_body = item.get_node(".") as Node3D
	var parent := item.get_parent()
	if parent:
		parent.remove_child(item)

	var entity_parent := character.get_parent()
	entity_parent.add_child(item)

	character.remove_relationship(RelationshipUtils.make_equipped(item))
	character.remove_relationship(RelationshipUtils.make_holding(item))

	item_body.freeze = false

	var drop_transform := get_drop_transform(character)
	item_body.global_transform = drop_transform

	return item


# TODO: to inventory utils
static func equip_weapon(character: ZE_Character, weapon: ZE_Weapon, _slot: String = "", replace: bool = true) -> bool:
	# TODO: make sure the character has the right slot

	if replace:
		var wielding := RelationshipUtils.get_wielding(character)
		for old_weapon in wielding:
			# TODO: check if they share the same slot
			unequip_item(character, old_weapon)

	if weapon == null:
		return true

	if equip_item(character, weapon):
		ZombieLogger.debug("Equipped weapon: {0}", [weapon.name])
		if EntityUtils.is_player(character) and EntityUtils.is_weapon(weapon):
			var menu := TreeUtils.get_menu(character)
			var player_ammo := character.get_component(ZC_Ammo) as ZC_Ammo
			menu.set_ammo_label(weapon, player_ammo)
		return true
	else:
		ZombieLogger.warning("Unable to equip weapon: {0}", [weapon.name])
		return false


# TODO: to inventory utils
## Equip an item and return true if the item could be equipped in its preferred slot
static func equip_item(character: ZE_Character, item: ZE_Base, _slot: String = "", _replace: bool = true) -> bool:
	var equipment := item.get_component(ZC_Equipment) as ZC_Equipment
	if equipment == null:
		return false

	# TODO: support multiple slots, find first unused
	var slots := character.equipment_slots
	if equipment.slot not in slots:
		return false

	# check if the slot is full (already has an item equipped)
	var slot_relationship := Relationship.new({
		ZC_Equipped: {
			"slot": {
				"_eq": equipment.slot
			},
		},
	}, null)
	var slot_equipped := character.get_relationship(slot_relationship)

	# TODO: support replacing existing item
	if slot_equipped:
		return false

	# finally, equip the item at the marker associated with the slot
	var previous_parent := item.get_parent()
	if previous_parent:
		previous_parent.remove_child(item)

	var parent := character.equipment_slots[equipment.slot]
	parent.add_child(item)

	character.add_relationship(RelationshipUtils.make_equipped(item))
	item.visible = parent.visible
	item.transform = Transform3D.IDENTITY

	var item_body = item.get_node(".") as Node3D
	var physics_mode := equipment.physics_mode

	# fall back to enabled when the body is not a RigidBody3D
	if item_body is not RigidBody3D:
		match physics_mode:
			ZC_Equipment.EquipmentPhysicsMode.STATIC:
				physics_mode = ZC_Equipment.EquipmentPhysicsMode.ENABLED
			ZC_Equipment.EquipmentPhysicsMode.KINEMATIC:
				physics_mode = ZC_Equipment.EquipmentPhysicsMode.ENABLED

	match physics_mode:
		ZC_Equipment.EquipmentPhysicsMode.DISABLED:
			TreeUtils.toggle_node(item_body, TreeUtils.NodeState.NONE, TreeUtils.NodeState.ENABLED)
		ZC_Equipment.EquipmentPhysicsMode.STATIC:
			CollisionUtils.freeze_body_static(item_body)
		ZC_Equipment.EquipmentPhysicsMode.KINEMATIC:
			CollisionUtils.freeze_body_kinematic(item_body)
		ZC_Equipment.EquipmentPhysicsMode.ENABLED:
			TreeUtils.toggle_node(item_body, TreeUtils.NodeState.ENABLED, TreeUtils.NodeState.ENABLED)
			if item_body is RigidBody3D:
				CollisionUtils.unfreeze_body(item_body)

	item.emit_action(Enums.ActionEvent.ITEM_EQUIP, character)

	return true


# TODO: to inventory utils
static func unequip_item(character: ZE_Character, item: ZE_Base) -> bool:
	var equipment := item.get_component(ZC_Equipment) as ZC_Equipment
	if equipment == null:
		return false

	var inventory_node := EntityUtils.get_inventory_node(character)
	if inventory_node == null:
		# TODO: drop item on ground instead
		return false

	var relationship := Relationship.new({
		ZC_Equipped: {
			"slot": {
				"_eq": equipment.slot,
			},
		},
	}, item)
	character.remove_relationship(relationship, 1)

	var parent := item.get_parent()
	if parent:
		parent.remove_child(item)

	inventory_node.add_item(item)
	item.transform = Transform3D.IDENTITY

	var item_body = item.get_node(".") as Node3D
	if item_body is RigidBody3D:
		CollisionUtils.freeze_body_static(item_body)

	item.emit_action(Enums.ActionEvent.ITEM_UNEQUIP, character)

	return true


static func get_players() -> Array[Entity]:
	return ECS.world.query.with_all([ZC_Player]).execute()


static func get_enemies() -> Array[Entity]:
	var characters := ECS.world.query.with_all([ZC_Faction]).execute() as Array[Entity]
	var enemies: Array[Entity] = []

	for character in characters:
		var faction := character.get_component(ZC_Faction) as ZC_Faction
		if faction.faction_name.begins_with("enemy_"):
			enemies.append(character)

	return enemies


static func is_broken(entity: Node) -> bool:
	if entity is not Entity:
		return false

	var durability := entity.get_component(ZC_Durability) as ZC_Durability
	if durability != null:
		return durability.current_durability <= 0

	return false


static func is_ammo_empty(ammo: ZC_Ammo) -> bool:
	for ammo_type in ammo.ammo_count:
		if ammo.ammo_count.get(ammo_type, 0) > 0:
			return false

	return true


static func is_enemy(entity: Node) -> bool:
	if entity is not Entity:
		return false

	var faction := entity.get_component(ZC_Faction) as ZC_Faction
	return faction.faction_name.begins_with("enemy_")


static func is_player(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Player)


static func is_explosive(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Explosive)


static func is_flammable(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Flammable)


static func is_interactive(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Interactive)


## Checks if the entity has the locked component **and** the is_locked flag is true
static func is_locked(entity: Node) -> bool:
	if entity is not Entity:
		return false

	var locked := entity.get_component(ZC_Locked) as ZC_Locked
	if locked == null:
		return false

	return locked.is_locked


static func is_objective(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Objective)


static func is_weapon(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return (
		entity.has_component(ZC_Weapon_Melee) or
		entity.has_component(ZC_Weapon_Ranged) or
		entity.has_component(ZC_Weapon_Thrown)
	)


static func is_melee_weapon(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Weapon_Melee)


static func is_ranged_weapon(entity: Node) -> bool:
	if entity is not Entity:
		return false

	if entity.has_component(ZC_Weapon_Ranged):
		return true

	if entity.has_component(ZC_Weapon_Thrown):
		return true

	return false


static func is_thrown_weapon(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Weapon_Thrown)


static func has_ammo(weapon: ZE_Weapon, ammos: Array[ZC_Ammo], min_count: int = 1) -> bool:
	if weapon is not Entity:
		return false

	var ranged_weapon := get_ranged_component(weapon)
	var ammo_type := ranged_weapon.ammo_type
	var total_count := 0
	for ammo in ammos:
		var ammo_count := ammo.get_ammo(ammo_type)
		if ammo_count > min_count:
			return true

		total_count += ammo_count
		if total_count > min_count:
			return true

	return false


static func has_shimmer(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Shimmer)


static func has_health(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Health)


static func get_damage_multiplier(entity: Node) -> float:
	var multiplier := 1.0
	if entity is not Entity:
		return multiplier

	var modifiers: Array[Relationship] = entity.get_relationships(RelationshipUtils.any_modifier)
	for relationship in modifiers:
		var modifier := relationship.target as Component
		if modifier is ZC_Effect_Armor:
			multiplier *= modifier.multiplier

	return multiplier


static func get_speed_multiplier(entity: Node) -> float:
	var multiplier := 1.0
	if entity is not Entity:
		return multiplier

	var modifiers: Array[Relationship] = entity.get_relationships(RelationshipUtils.any_modifier)
	for relationship in modifiers:
		var modifier := relationship.target as Component
		if modifier is ZC_Effect_Speed:
			multiplier *= modifier.multiplier

	return multiplier


static func get_screen_effects(entity: Node) -> Dictionary[ZM_BaseMenu.Effects, float]:
	var max_effects: Dictionary[ZM_BaseMenu.Effects, float] = {}

	# TODO: remove or cache this loop
	for effect_type in ZM_BaseMenu.Effects.values():
		if effect_type == ZM_BaseMenu.Effects.NONE:
			continue

		max_effects[effect_type] = 0.0

	var effects := entity.get_relationships(RelationshipUtils.any_effect) as Array[Relationship]
	for rel in effects:
		var effect := rel.target as ZC_Screen_Effect
		var effect_strength := effect.current_strength()
		var prev_strength := max_effects.get(effect.effect, 0.0) as float
		if effect_strength > prev_strength:
			max_effects[effect.effect] = effect_strength

	return max_effects


static func remove_immediate(entity: Node) -> void:
	if entity is Entity:
		ECS.world.remove_entity(entity)
		if entity.has_component(ZC_Persistent):
			SaveManager.deleted_ids.append(entity.id)

	var parent = entity.get_parent()
	if parent:
		parent.remove_child(entity)

	entity.queue_free()


static func remove(entity: Node) -> void:
	remove_immediate.call_deferred(entity)


static func upsert(entity: Entity) -> void:
	var existing := ECS.world.get_entity_by_id(entity.id)
	if existing == null:
		ECS.world.add_entity(entity)
	else:
		assert(false, "TODO: implement entity update in upsert")

static func find_sounds(entity: Node3D) -> Array[ZN_AudioSubtitle3D]:
	if entity is ZN_AudioSubtitle3D:
		return [entity]

	var results: Array[ZN_AudioSubtitle3D] = []
	for child in entity.get_children():
		if child is ZN_AudioSubtitle3D:
			results.append(child)
		elif child is Node3D:
			results.append_array(EntityUtils.find_sounds(child))

	return results

static func keep_sounds(entity: Node, target: Node = null, remove_on_finish: bool = true) -> Array[ZN_AudioSubtitle3D]:
	assert(entity is Node3D, "entity must be a 3D node")
	if target == null:
		target = entity.get_parent()
	assert(target != null, "target must not be null")

	# TODO: make sure sound position works correctly with non-3D parent
	# assert(target is Node3D, "target must be 3D node")
	assert(target is Node, "target must be a node")

	var sounds := find_sounds(entity)
	for sound in sounds:
		var sound_position = sound.global_position
		var sound_rotation = sound.global_rotation
		sound.get_parent().remove_child(sound)
		target.add_child(sound)
		sound.global_position = sound_position
		sound.global_rotation = sound_rotation

		if remove_on_finish:
			sound.finished.connect(sound.queue_free)

	return sounds


static func get_ranged_component(weapon: ZE_Weapon) -> ZC_Weapon_Ranged:
	if weapon is not Entity:
		return null

	var ranged := weapon.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
	if ranged != null:
		return ranged

	var thrown := weapon.get_component(ZC_Weapon_Thrown) as ZC_Weapon_Thrown
	return thrown


# TODO: to inventory utils
static func switch_weapon(entity: ZE_Character, new_weapon: ZE_Weapon, menu: ZM_Menu) -> void:
	var previous_weapons := RelationshipUtils.get_wielding(entity)
	var equipped := EntityUtils.equip_weapon(entity, new_weapon)
	if not equipped:
		return

	if new_weapon == null:
		menu.clear_weapon_label()
		menu.clear_ammo_label()

		if previous_weapons.size() > 0:
			var old_weapon := previous_weapons[0]
			var old_interactive := old_weapon.get_component(ZC_Interactive) as ZC_Interactive
			var message_text := "Holstered weapon: %s" % old_interactive.name
			var message_icon := Icons.get_weapon_icon(old_weapon)
			menu.append_message(ZC_Message.make_interaction(message_text, message_icon))

		# set remote transform to a known state
		entity.weapon_follower.progress_ratio = 0.0
		return

	if EntityUtils.is_melee_weapon(new_weapon):
		entity.weapon_follower.progress_ratio = 0.0

	new_weapon.emit_action(Enums.ActionEvent.ENTITY_EQUIP, entity)

	var c_interactive = new_weapon.get_component(ZC_Interactive) as ZC_Interactive
	var message_text := "Switched to weapon: %s" % c_interactive.name
	var message_icon := Icons.get_weapon_icon(new_weapon)
	menu.append_message(ZC_Message.make_interaction(message_text, message_icon))
	menu.set_weapon_label(c_interactive.name)

	if c_interactive.use_sound:
		var sound := c_interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound)


# TODO: to inventory utils
static func reload_weapon(player: ZE_Character) -> void:
	for weapon in RelationshipUtils.get_wielding(player):
		var weapon_ammo := weapon.get_component(ZC_Ammo) as ZC_Ammo
		if weapon_ammo == null:
			return

		var ranged_weapon := EntityUtils.get_ranged_component(weapon)
		if ranged_weapon == null:
			return

		var player_ammo := player.get_component(ZC_Ammo) as ZC_Ammo
		if player_ammo.get_ammo(ranged_weapon.ammo_type) == 0:
			return

		weapon_ammo.transfer(player_ammo)
		weapon.apply_effects(ZR_Weapon_Effect.EffectType.RANGED_RELOAD)


# TODO: to inventory utils
## This does not get the list of inventory items. You probably want RelationshipUtils.get_inventory()
static func get_inventory_node(entity: Entity) -> ZN_Inventory:
	var inventory_component := entity.get_component(ZC_Inventory) as ZC_Inventory
	if inventory_component == null:
		return null

	var inventory_node := entity.get_node_or_null(inventory_component.node_path) as ZN_Inventory
	return inventory_node
