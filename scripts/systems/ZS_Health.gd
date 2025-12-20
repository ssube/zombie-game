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

			if EntityUtils.is_objective(entity):
				var objective: ZC_Objective = entity.get_component(ZC_Objective)
				if objective.is_active and objective.complete_on_damage:
					objective.is_complete = true

		if health.current_health <= 0:
			assert(health.current_health == 0, "Health is negative!")
			print("Entity has perished: ", entity)

			if EntityUtils.is_objective(entity):
				var objective: ZC_Objective = entity.get_component(ZC_Objective)
				if objective.is_active and objective.complete_on_death:
					objective.is_complete = true

			if EntityUtils.is_explosive(entity):
				var explosive: ZC_Explosive = entity.get_component(ZC_Explosive)
				if explosive.explode_on_death:
					var explosion = explosive.explosion_scene.instantiate() as Node3D
					var entity_node: Node3D = entity.get_node(".") as Node3D

					# Place the explosion at the same position as the entity
					var root = entity.get_parent()
					root.add_child(explosion)
					explosion.global_transform = entity_node.global_transform

					# Remove the exploded entity
					print("Entity has exploded: ", entity)
					EntityUtils.keep_sounds(entity)
					EntityUtils.remove(entity)
