extends System
class_name ZS_StaminaSystem

func query() -> QueryBuilder:
	return q.with_all([ZC_Stamina])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var stamina := entity.get_component(ZC_Stamina) as ZC_Stamina
		if stamina.current_stamina >= stamina.max_stamina:
			continue

		var input := entity.get_component(ZC_Input) as ZC_Input
		if input != null:
			if input.move_jump or input.move_sprint or input.use_any:
				continue

		# Only recharge if they are still
		var velocity := entity.get_component(ZC_Velocity) as ZC_Velocity
		var recharge: float = 0.0
		if is_zero_approx(velocity.linear_velocity.length_squared()):
			recharge += stamina.still_recharge_rate * delta
		else:
			recharge += stamina.moving_recharge_rate * delta

		stamina.current_stamina += recharge
		if EntityUtils.is_player(entity):
			%Menu.set_stamina(stamina.current_stamina)
