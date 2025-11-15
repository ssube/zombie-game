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
			# print("Bullet is colliding with: ", target)

			if target is Entity:
				projectile.piercing -= 1
				if target.has_component(ZC_Health):
					var damage = ZC_Damage.new(projectile.damage)
					target.add_component(damage)

				if target.has_component(ZC_Flammable):
					var flammable: ZC_Flammable = target.get_component(ZC_Flammable)
					if flammable.ignite_on_hit:
						var fire = ZC_Effect_Burning.new()
						target.add_component(fire)

						var effect_node = target.get_node(flammable.effect_path) as Node3D
						effect_node.visible = true

			if projectile.piercing <= 0:
				print("Bullet has expired: ", entity)
				var root := entity.get_parent()
				root.remove_child(entity)
				ECS.world.remove_entity(entity)
