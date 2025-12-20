extends ZB_State
class_name ZB_State_Attack

var attack_timer: float = 0.0

func tick(entity: Entity, delta: float, _blackboard: ZB_Blackboard) -> TickResult:
		var attention := entity.get_component(ZC_Attention) as ZC_Attention
		if attention == null or not attention.has_target_entity:
				return TickResult.FORCE_EXIT

		var target_entity := ECS.world.get_entity_by_id(attention.target_entity)
		if target_entity == null:
				# Target was removed from world (died, etc.)
				attention.target_entity = ""
				return TickResult.FORCE_EXIT

		var target_position: Vector3 = target_entity.global_position

		if entity.current_weapon == null:
				switch_weapon(entity)

		if entity.current_weapon == null:
				return TickResult.FORCE_EXIT

		var movement := entity.get_component(ZC_Movement) as ZC_Movement
		movement.target_look_position = target_position

		attack_timer -= delta
		if attack_timer > 0.0:
				return TickResult.CONTINUE

		print("Zombie attacks player! ", target_entity.name)

		var weapon = entity.current_weapon as ZE_Weapon
		if EntityUtils.is_broken(weapon):
				weapon = switch_weapon(entity)

		var melee_weapon = weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
		attack_timer = melee_weapon.cooldown_time

		var swing_node = weapon.get_node(melee_weapon.swing_path) as PathFollow3D
		swing_node.progress_ratio = 0.0

		var tween = weapon.create_tween()
		tween.tween_property(swing_node, "progress_ratio", 1.0, melee_weapon.swing_time)
		tween.tween_property(swing_node, "progress_ratio", 0.0, melee_weapon.cooldown_time)

		return TickResult.CHECK


func switch_weapon(entity: Entity) -> ZE_Weapon:
		if entity is not ZE_Character:
				return null

		var entity_ammo := entity.get_component(ZC_Ammo) as ZC_Ammo
		var inventory := entity.inventory_node.get_children() as Array[Node]
		for item in inventory:
				if EntityUtils.is_weapon(item):
						var loaded := EntityUtils.has_ammo(item, [entity_ammo])
						var broken := EntityUtils.is_broken(item)
						if loaded and not broken:
								EntityUtils.equip_weapon(entity, item)

		return null
