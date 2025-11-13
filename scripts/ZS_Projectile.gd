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

			if target is ZE_Zombie:
				var zombie = target as ZE_Zombie
				var damage = ZC_Damage.new(projectile.damage)
				zombie.add_component(damage)
