class_name EntityUtils


static func apply_damage(entity: Node, base_damage: int, base_multiplier: float = 1.0) -> int:
	if entity is not Entity:
		return 0

	if not EntityUtils.has_health(entity):
		return 0

	var multiplier: float = EntityUtils.get_damage_multiplier(entity)
	multiplier *= base_multiplier

	var damage: int = floor(base_damage * multiplier)
	entity.add_relationship(RelationshipUtils.make_damage(damage))
	return damage


static func drop_weapon(character: ZE_Character) -> ZE_Weapon:
	var old_weapon := character.current_weapon
	if old_weapon == null:
		return null

	character.current_weapon = null

	var weapon_body = old_weapon.get_node(".") as RigidBody3D
	var weapon_position := weapon_body.global_position as Vector3
	var weapon_parent := old_weapon.get_parent()
	if weapon_parent:
		weapon_parent.remove_child(old_weapon)

	var entity_parent := character.get_parent()
	entity_parent.add_child(old_weapon)

	old_weapon.remove_relationship(RelationshipUtils.make_equipped(old_weapon))
	old_weapon.remove_relationship(RelationshipUtils.make_holding(old_weapon))

	weapon_body.freeze = false
	weapon_body.global_position = weapon_position

	return old_weapon


static func equip_weapon(character: ZE_Character, weapon: ZE_Weapon) -> ZE_Weapon:
	var old_weapon := character.current_weapon
	if old_weapon != null:
		old_weapon.get_parent().remove_child(old_weapon)
		old_weapon.visible = false
		character.inventory_node.add_child(old_weapon)
		character.remove_relationship(RelationshipUtils.make_equipped(old_weapon))

	character.current_weapon = weapon
	if weapon != null:
		var weapon_parent := weapon.get_parent()
		if weapon_parent:
			weapon_parent.remove_child(weapon)

		weapon.visible = true
		character.hands_node.add_child(weapon)
		character.add_relationship(RelationshipUtils.make_equipped(weapon))

	return old_weapon


static func get_players() -> Array[Entity]:
	return ECS.world.query.with_all([ZC_Player]).execute()


static func get_enemies() -> Array[Entity]:
	return ECS.world.query.with_all([ZC_Enemy]).execute()


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


static func is_player(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Player)


static func is_zombie(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Enemy)


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
		entity.has_component(ZC_Weapon_Ranged)
	)


static func is_melee_weapon(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Weapon_Melee)


static func is_ranged_weapon(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Weapon_Ranged)


static func has_ammo(weapon: ZE_Weapon, ammos: Array[ZC_Ammo], min_count: int = 1) -> bool:
	if weapon is not Entity:
		return false

	var ranged_weapon := weapon.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
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


static func remove(entity: Node) -> void:
	if entity is Entity:
		ECS.world.remove_entity(entity)

	var parent = entity.get_parent()
	if parent:
		parent.remove_child(entity)

	entity.queue_free()


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
