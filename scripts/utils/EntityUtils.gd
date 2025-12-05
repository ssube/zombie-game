class_name EntityUtils

static func is_player(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Player)

static func is_zombie(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Enemy)

static func is_flammable(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Flammable)

static func is_interactive(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Interactive)

static func has_shimmer(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Shimmer)

static func has_health(entity: Node) -> bool:
	if entity is not Entity:
		return false

	return entity.has_component(ZC_Health)
