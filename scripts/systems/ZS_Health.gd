class_name ZS_HealthSystem
extends System

func query():
	return q.with_all([ZC_Health])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		if entity == null:
			printerr("Processing null entity")
			continue

		var damages := entity.get_relationships(RelationshipUtils.any_damage) as Array[Relationship]
		if damages.size() == 0:
			continue

		var total_damage := 0
		for damage_rel in damages:
			var c_damage := damage_rel.target as ZC_Damage
			total_damage += floor(c_damage.amount)
			entity.remove_relationship(damage_rel)

		var damage: int = total_damage
		# Do not apply damage resistance to healing (negative damage)
		if damage > 0:
			var multiplier: float = EntityUtils.get_damage_multiplier(entity)
			damage = floor(total_damage * multiplier)

		var health := entity.get_component(ZC_Health) as ZC_Health
		health.current_health -= damage

		if damage > 0:
			if EntityUtils.is_player(entity):
				var effect_strength := 1.0 - (health.current_health / float(health.max_health))
				effect_strength /= 2.0

				var effect := ZC_Screen_Effect.new()
				effect.effect = ZM_BaseMenu.Effects.DAMAGE
				effect.duration = effect_strength * 5.0
				effect.strength = effect_strength
				var effect_rel := RelationshipUtils.make_effect(effect)
				entity.add_relationship(effect_rel)
