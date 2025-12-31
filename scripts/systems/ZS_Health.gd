class_name ZS_HealthSystem
extends System

enum HealthMode {
	LAST_DAMAGE,
	MOST_DAMAGE,
}

@export var mode: HealthMode = HealthMode.LAST_DAMAGE


func query():
	return q.with_all([ZC_Health]).with_relationship([RelationshipUtils.any_damage])


func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		if entity == null:
			printerr("Processing null entity")
			continue

		var damages := RelationshipUtils.get_damage(entity)
		if damages.size() == 0:
			continue

		var health := entity.get_component(ZC_Health) as ZC_Health
		_apply_damage(entity, health, damages)
		_apply_healing(entity, health, damages)
		entity.remove_relationships(damages)


func _calculate_damage_source(damages: Array[Relationship]) -> String:
	match mode:
		HealthMode.LAST_DAMAGE:
			return _calculate_last_damage_source(damages)
		HealthMode.MOST_DAMAGE:
			return _calculate_most_damage_source(damages)

	assert(false, "Invalid damage mode!")
	return ""


func _calculate_last_damage_source(damages: Array[Relationship]) -> String:
	var last_source :=  ""
	var max_timestamp := 0.0

	for damage in damages:
		var relation := damage.relation as ZC_Damaged
		if relation.damaged_at > max_timestamp:
			last_source = relation.damaged_by
			max_timestamp = relation.damaged_at

	return last_source


func _calculate_most_damage_source(damages: Array[Relationship]) -> String:
	var damage_by_source: Dictionary[String, int] = {}

	for damage in damages:
		var relation := damage.relation as ZC_Damaged
		damage_by_source[relation.damaged_by] = damage_by_source.get(relation.damaged_by, 0) + damage.target.amount

	var max_source := ""
	var max_damage := 0

	for source in damage_by_source.keys():
		var amount := damage_by_source[source]
		if amount > max_damage:
			max_source = source
			max_damage = amount

	return max_source


func _apply_damage(entity: Entity, health: ZC_Health, damages: Array[Relationship]) -> void:
	if EntityUtils.is_player(entity) and OptionsManager.options.cheats.god_mode:
		return

	var total_damage := 0
	for damage_rel in damages:
		var c_damage := damage_rel.target as ZC_Damage
		if c_damage.amount > 0:
			total_damage += floor(c_damage.amount)

	var real_damage = floori(total_damage * EntityUtils.get_damage_multiplier(entity))

	if real_damage <= 0:
		return

	var previous_health := health.current_health
	var adjusted_health := maxi(previous_health - total_damage, 0)

	var damage_source := _calculate_damage_source(damages)
	var hit_by := ECS.world.get_entity_by_id(damage_source)

	if hit_by:
		var hit := Relationship.new(ZC_Hit.new(), hit_by)
		RelationshipUtils.add_unique_relationship(entity, hit)

		# TODO: find a better way to only add this once per entity
		# the observer already has both of these values, for example
		if adjusted_health <= 0 and previous_health > 0:
			var killed := Relationship.new(ZC_Killed.new(damage_source), entity)
			hit_by.add_relationship(killed)

	if EntityUtils.is_player(entity):
		var effect_strength := 1.0 - (adjusted_health / float(health.max_health))
		effect_strength /= 2.0

		var effect := ZC_Screen_Effect.new()
		effect.effect = ZM_BaseMenu.Effects.DAMAGE
		effect.duration = effect_strength * 5.0
		effect.strength = effect_strength
		var effect_rel := RelationshipUtils.make_effect(effect)
		entity.add_relationship(effect_rel)

	# Should happen as the last step, once all of the relationships are in place
	health.current_health -= real_damage


func _apply_healing(_entity: Entity, health: ZC_Health, damages: Array[Relationship]) -> void:
	var total_healing := 0
	for damage_rel in damages:
		var c_damage := damage_rel.target as ZC_Damage
		if c_damage.amount < 0:
			total_healing += ceili( -c_damage.amount )

	if total_healing <= 0:
		return

	health.current_health += total_healing
