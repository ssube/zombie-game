class_name RelationshipUtils

static var any_damage = Relationship.new(ZC_Damaged.new(), null)
static var any_effect = Relationship.new(ZC_Effected.new(), null)
static var any_holding = Relationship.new(ZC_Holding.new(), null)
static var any_modifier = Relationship.new(ZC_Modifier.new(), null)
static var any_wearing = Relationship.new(ZC_Wearing.new(), null)
static var any_used = Relationship.new(ZC_Used.new(), null)

static func get_holder(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_reverse_relationship([
		RelationshipUtils.make_holding(item)
	]).execute() as Array[Relationship]
	assert(relationships.size() <= 1, "Item has more than one entity holding it, relationships are leaking!")
	return relationships.get(0)

static func get_wearer(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_reverse_relationship([
		RelationshipUtils.make_wearing(item)
	]).execute() as Array[Relationship]
	assert(relationships.size() <= 1, "Item has more than one entity wearing it, relationships are leaking!")
	return relationships.get(0)

static func get_user(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_reverse_relationship([
		RelationshipUtils.make_used(item)
	]).execute() as Array[Relationship]
	assert(relationships.size() <= 1, "Item has more than one entity using it, relationships are leaking!")
	return relationships.get(0)

static func make_damage(damage_amount: int) -> Relationship:
	var damage_component := ZC_Damage.new(damage_amount)
	var damaged_component := ZC_Damaged.new()
	return Relationship.new(damaged_component, damage_component)

static func make_effect(effect: ZC_Screen_Effect) -> Relationship:
	var effected_component := ZC_Effected.new()
	return Relationship.new(effected_component, effect)

static func make_equipped(item: Entity) -> Relationship:
	var equipped_component := ZC_Equipped.new()
	return Relationship.new(equipped_component, item)

static func make_holding(item: Entity) -> Relationship:
	var holding_component := ZC_Holding.new()
	return Relationship.new(holding_component, item)

static func make_wearing(item: Entity) -> Relationship:
	var wearing_component := ZC_Wearing.new()
	return Relationship.new(wearing_component, item)

static func make_used(item: Entity) -> Relationship:
	var used_component := ZC_Used.new()
	return Relationship.new(used_component, item)

static func make_modifier_damage(multiplier: float) -> Relationship:
	var damage_modifier := ZC_Effect_Armor.new(multiplier)
	var link = ZC_Modifier.new()
	return Relationship.new(link, damage_modifier)

static func make_modifier_speed(multiplier: float) -> Relationship:
	var speed_modifier := ZC_Effect_Speed.new(multiplier)
	var link = ZC_Modifier.new()
	return Relationship.new(link, speed_modifier)
