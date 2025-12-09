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
			var target_object = ray.get_collider()
			var target_shape = CollisionUtils.get_collision_shape(ray)

			print("Bullet is colliding with: ", target_object, ", ", target_shape)
			apply_decal(ray, target_object)
			apply_sound(ray, target_object)

			if target_object is RigidBody3D:
				var impact_vector: Vector3 = ray.get_collision_normal() * -projectile.mass
				target_object.apply_impulse(impact_vector)

			if target_object is Entity:
				var body_regions = target_object.get_component(ZC_Body_Regions) as ZC_Body_Regions

				var region_multiplier := 1.0
				if body_regions:
					for region in body_regions.regions:
						var region_shape = target_object.get_node(region)
						if target_shape == region_shape:
							region_multiplier *= body_regions.regions[region]

				EntityUtils.apply_damage(target_object, projectile.damage, region_multiplier)

				if EntityUtils.is_flammable(target_object):
					var flammable: ZC_Flammable = target_object.get_component(ZC_Flammable)
					if flammable.ignite_on_hit:
						var fire = ZC_Effect_Burning.new()
						target_object.add_component(fire)

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
	%Menu.push_action(sound_node.subtitle_tag)
	sound_node.play_subtitle()
