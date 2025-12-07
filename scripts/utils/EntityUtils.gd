class_name EntityUtils


static func apply_damage(entity: Node, base_damage: int) -> int:
	if entity is not Entity:
		return 0

	if not EntityUtils.has_health(entity):
		return 0

	var multiplier: float = EntityUtils.get_damage_multiplier(entity)
	var damage: int = floor(base_damage * multiplier)
	entity.add_relationship(RelationshipUtils.make_damage(damage))
	return damage


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
