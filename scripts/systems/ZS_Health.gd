class_name ZS_HealthSystem
extends System

func query():
	return q.with_all([ZC_Health])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var health := entity.get_component(ZC_Health) as ZC_Health

		# var damage := entity.get_component(ZC_Damage) as ZC_Damage
		var damages := entity.get_relationships(RelationshipUtils.any_damage) as Array[Relationship]
		if damages.size() == 0:
			continue

		for damage_rel in damages:
			var damage: ZC_Damage = damage_rel.target as ZC_Damage
			health.current_health = max(0, health.current_health - floor(damage.amount))
			entity.remove_relationship(damage_rel)

		var skin := entity.get_component(ZC_Skin) as ZC_Skin
		if health.current_health <= 0:
			health.current_health = 0
			print("Entity has perished: ", entity)

			if skin != null and skin.material_dead != null:
				update_skin_material(entity, skin, skin.material_dead)

			if EntityUtils.is_flammable(entity):
				var flammable: ZC_Flammable = entity.get_component(ZC_Flammable)
				if flammable.explode_on_death:
					var explosion = flammable.explosion_scene.instantiate() as Node3D
					var entity_node: Node3D = entity.get_node(".") as Node3D

					# Place the explosion at the same position as the entity
					var root = entity.get_parent()
					explosion.global_transform = entity_node.global_transform
					root.add_child(explosion)

					# Remove the exploded entity
					# TODO: this is cutting off explosion sounds
					# entity.visible = false
					print("Entity has exploded: ", entity)
					ECS.world.remove_entity(entity)
					root.remove_child(entity)
					entity.queue_free()
		elif health.current_health < health.max_health:
			if skin != null and skin.material_injured != null:
				update_skin_material(entity, skin, skin.material_injured)

func update_skin_material(entity: Node, skin: ZC_Skin, material: BaseMaterial3D):
	for shape_path in skin.skin_shapes:
		var shape = entity.get_node(shape_path) as GeometryInstance3D
		shape.material_overlay = material
