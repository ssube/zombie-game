extends ZB_State
class_name ZB_State_Attack

var attack_timer: float = 0.0

func tick(entity: Entity, delta: float, blackboard: ZB_Blackboard) -> TickResult:
	var target_player = blackboard.get_value(BehaviorUtils.target_player)
	if target_player == null:
		return TickResult.FORCE_EXIT

	if entity.current_weapon == null:
		return TickResult.FORCE_EXIT

	entity.look_at_target(target_player.global_position)

	attack_timer -= delta
	if attack_timer > 0.0:
		return TickResult.CONTINUE

	print("Zombie attacks player! ", target_player)

	var weapon = entity.current_weapon as ZE_Weapon
	var c_weapon = weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
	# target_player.add_relationship(RelationshipUtils.make_damage(c_weapon.damage))
	attack_timer = c_weapon.cooldown_time

	var swing_node = weapon.get_node(c_weapon.swing_path) as PathFollow3D
	swing_node.progress_ratio = 0.0

	var tween = weapon.create_tween()
	tween.tween_property(swing_node, "progress_ratio", 1.0, c_weapon.swing_time)
	tween.tween_property(swing_node, "progress_ratio", 0.0, c_weapon.cooldown_time)

	return TickResult.CHECK
