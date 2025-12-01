class_name RelationshipUtils

static func make_damage(damage_amount: int) -> Relationship:
	var damage_component := ZC_Damage.new(damage_amount)
	var damaged_component := ZC_Damaged.new()
	return Relationship.new(damaged_component, damage_component)

static func make_equipped(item: Entity) -> Relationship:
	var equipped_component := ZC_Equipped.new()
	return Relationship.new(equipped_component, item)

static func make_holding(item: Entity) -> Relationship:
	var holding_component := ZC_Holding.new()
	return Relationship.new(holding_component, item)
