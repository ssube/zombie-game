extends System
class_name ZS_StaminaSystem

func query() -> QueryBuilder:
	return q.with_all([ZC_Stamina])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var stamina := entity.get_component(ZC_Stamina) as ZC_Stamina
		if stamina.current_stamina >= stamina.max_stamina:
			continue

		# Only recharge if they are still
		var velocity := entity.get_component(ZC_Velocity) as ZC_Velocity
		var recharge: float = 0.0
		if is_zero_approx(velocity.linear_velocity.length_squared()):
			recharge += stamina.still_recharge_rate
		else:
			recharge += stamina.moving_recharge_rate

		# Apply cost
		var input := entity.get_component(ZC_Input) as ZC_Input
		var cost: float = velocity.linear_velocity.length() * stamina.velocity_multiplier
		if input and input.move_sprint:
			cost *= stamina.sprint_multiplier

		var change := (recharge - cost) * delta
		stamina.current_stamina += change

		if EntityUtils.is_player(entity):
			%Menu.set_stamina(stamina.current_stamina)
