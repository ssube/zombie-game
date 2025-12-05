class_name ZS_ProjectileSystem
extends System

var impact_sound = preload("res://effects/impacts/impact_bullet_metal.tscn")

func query():
	return q.with_all([ZC_Projectile])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var projectile = entity.get_component(ZC_Projectile)
		var ray = entity.get_node(projectile.collision_ray) as RayCast3D

		if ray != null and ray.is_colliding():
			var target = ray.get_collider()
			print("Bullet is colliding with: ", target)
			apply_decal(ray, target)
			apply_sound(ray, target)

			if target is RigidBody3D:
				var impact_vector: Vector3 = ray.get_collision_normal() * -projectile.mass
				target.apply_impulse(impact_vector)

			if target is Entity:
				if EntityUtils.has_health(target):
					target.add_relationship(RelationshipUtils.make_damage(projectile.damage))

				if EntityUtils.is_flammable(target):
					var flammable: ZC_Flammable = target.get_component(ZC_Flammable)
					if flammable.ignite_on_hit:
						var fire = ZC_Effect_Burning.new()
						target.add_component(fire)

			projectile.piercing -= 1
			if projectile.piercing <= 0:
				print("Bullet has expired: ", entity)
				EntityUtils.remove(entity)

func apply_decal(ray: RayCast3D, collider: Node3D) -> void:
	# Obtain collision info
	var collision_point = ray.get_collision_point()
	var collision_normal = ray.get_collision_normal()

	# Determine surface type. This example uses node groups.
	var surface_type = ""
	if collider.is_in_group("wood"):
			surface_type = "wood"
	elif collider.is_in_group("metal"):
			surface_type = "metal"
	elif collider.is_in_group("stone"):
			surface_type = "stone"
	else:
			surface_type = "default"

	# Spawn the decal via the manager singleton.
	DecalManager.spawn_decal(surface_type, collider, collision_point, collision_normal)

func apply_sound(ray: RayCast3D, collider: Node3D) -> void:
	# Obtain collision info
	var collision_point = ray.get_collision_point()

	var sound_node = impact_sound.instantiate() as ZN_AudioSubtitle3D
	collider.add_child(sound_node)
	sound_node.global_position = collision_point
	%Hud.push_action(sound_node.subtitle_tag)
	sound_node.play_subtitle()
