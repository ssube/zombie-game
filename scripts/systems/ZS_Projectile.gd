class_name ZS_ProjectileSystem
extends System

func query():
	return q.with_all([ZC_Projectile])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var projectile = entity.get_component(ZC_Projectile)
		var ray = entity.get_node(projectile.collision_ray) as RayCast3D

		if ray != null and ray.is_colliding():
			var target = ray.get_collider()
			print("Bullet is colliding with: ", target)

			if target is RigidBody3D:
				var impact_vector: Vector3 = ray.get_collision_normal() * -projectile.mass
				target.apply_impulse(impact_vector)

			if target is Entity:
				if target.has_component(ZC_Health):
					target.add_relationship(RelationshipUtils.make_damage(projectile.damage))

				if target.has_component(ZC_Flammable):
					var flammable: ZC_Flammable = target.get_component(ZC_Flammable)
					if flammable.ignite_on_hit:
						var fire = ZC_Effect_Burning.new()
						target.add_component(fire)

			projectile.piercing -= 1
			if projectile.piercing <= 0:
				print("Bullet has expired: ", entity)
				ECS.world.remove_entity(entity)
				var root := entity.get_parent()
				root.remove_child(entity)
				entity.queue_free()
