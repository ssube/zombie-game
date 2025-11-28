class_name RelationshipUtils

static func add_damage(damage_amount: int) -> Relationship:
	var damage_component := ZC_Damage.new(damage_amount)
	var damaged_component := ZC_Damaged.new()
	return Relationship.new(damaged_component, damage_component)