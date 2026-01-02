class_name RelationshipUtils

static var any_damage = Relationship.new(ZC_Damaged.new(""), null)
static var any_effect = Relationship.new(ZC_Effected.new(), null)
static var any_equipped = Relationship.new(ZC_Equipped.new(), null)
static var any_fired = Relationship.new(ZC_Fired.new(), null)
static var any_heard = Relationship.new(ZC_Heard.new(), null)
static var any_hit = Relationship.new(ZC_Hit.new(), null)
static var any_holding = Relationship.new(ZC_Holding.new(), null)
static var any_modifier = Relationship.new(ZC_Modifier.new(), null)
static var any_detected = Relationship.new(ZC_Detected.new(), null)
static var any_wearing = Relationship.new(ZC_Wearing.new(), null)
static var any_used = Relationship.new(ZC_Used.new(), null)

static func add_unique_relationship(target: Entity, relationship: Relationship) -> void:
	var similar_relationship := Relationship.new(relationship.relation, null)
	var existing_relationships := target.get_relationships(similar_relationship)
	target.remove_relationships(existing_relationships)
	target.add_relationship(relationship)

static func get_damage(target: Entity) -> Array[Relationship]:
	var relationships := target.get_relationships(any_damage) as Array[Relationship]
	return relationships

static func get_holder(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_reverse_relationship([
		RelationshipUtils.make_holding(item)
	]).execute() as Array[Entity]
	assert(relationships.size() <= 1, "Item has more than one entity holding it, relationships are leaking!")

	if relationships.size() == 0:
		return null

	return relationships.get(0)

static func get_killer(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_relationship([
		Relationship.new(ZC_Killed.new(""), item),
	]).execute() as Array
	assert(relationships.size() <= 1, "Item has been killed by more than one entity, relationships are leaking!")

	if relationships.size() == 0:
		return null

	return relationships.get(0)

static func get_user(target: Entity) -> Entity:
	var relationships := target.get_relationships(any_used) as Array[Relationship]
	assert(relationships.size() <= 1, "Item has more than one entity using it, relationships are leaking!")
	return relationships.get(0).target

static func get_wearer(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_reverse_relationship([
		RelationshipUtils.make_wearing(item)
	]).execute() as Array[Entity]
	assert(relationships.size() <= 1, "Item has more than one entity wearing it, relationships are leaking!")
	return relationships.get(0)

static func get_wielder(item: Entity) -> Entity:
	var relationships := ECS.world.query.with_relationship([
		RelationshipUtils.make_equipped(item),
	]).execute() as Array
	assert(relationships.size() <= 1, "Item has more than one entity wielding it, relationships are leaking!")
	return relationships.get(0)

static func get_inventory(target: Entity) -> Array[Entity]:
	var relationships := target.get_relationships(RelationshipUtils.any_holding)
	var entities: Array[Entity] = []
	for rel in relationships:
		entities.append(rel.target)

	return entities


static func make_damage(actor: Entity, damage_amount: int) -> Relationship:
	var actor_id := ""
	if actor:
		actor_id = actor.id

	var damage_component := ZC_Damage.new(damage_amount, actor_id)
	var damage_link := ZC_Damaged.new(actor_id)
	damage_link.damaged_by = actor_id
	return Relationship.new(damage_link, damage_component)

static func make_detected(stimulus: ZC_Stimulus) -> Relationship:
	var detected_component := ZC_Detected.new()
	return Relationship.new(detected_component, stimulus)

static func make_effect(effect: ZC_Screen_Effect) -> Relationship:
	var effected_component := ZC_Effected.new()
	return Relationship.new(effected_component, effect)

static func make_equipped(item: Entity) -> Relationship:
	var equipped_component := ZC_Equipped.new()
	return Relationship.new(equipped_component, item)

static func make_fired(actor: Entity) -> Relationship:
	var fired_component := ZC_Fired.new()
	return Relationship.new(fired_component, actor)

static func make_heard(sound: ZC_Noise) -> Relationship:
	var heard_component := ZC_Heard.new()
	return Relationship.new(heard_component, sound)

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


static func get_weapons(entity: Entity) -> Array[ZE_Weapon]:
	var weapons: Array[ZE_Weapon] = []
	var inventory := RelationshipUtils.get_inventory(entity)
	for item in inventory:
		if EntityUtils.is_weapon(item):
			weapons.append(item as ZE_Weapon)

	return weapons
