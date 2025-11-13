class_name ZS_HealthSystem
extends System

func query():
	return q.with_all([ZC_Damage, ZC_Health])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var damage := entity.get_component(ZC_Damage) as ZC_Damage
		var health := entity.get_component(ZC_Health) as ZC_Health
		var skin := entity.get_component(ZC_Skin) as ZC_Skin

		health.current_health -= floor(damage.amount)
		entity.remove_component(damage)

		if health.current_health <= 0:
			health.current_health = 0
			print("Entity has perished: ", entity)

			if skin != null and skin.material_dead != null:
				var shape = entity.get_node(skin.skin_shape) as GeometryInstance3D
				shape.material_override = skin.material_dead
		elif health.current_health < health.max_health:
			if skin != null and skin.material_injured != null:
				var shape = entity.get_node(skin.skin_shape) as GeometryInstance3D
				shape.material_override = skin.material_injured
