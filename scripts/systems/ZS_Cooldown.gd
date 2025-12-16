extends System
class_name ZS_CooldownSystem

func query() -> QueryBuilder:
	return q.with_all([ZC_Cooldown])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var cooldown := entity.get_component(ZC_Cooldown) as ZC_Cooldown
		if cooldown.time_remaining > 0:
			cooldown.time_remaining -= delta

		if cooldown.time_remaining <= 0:
			entity.remove_component(cooldown)
