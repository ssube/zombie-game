class_name ZS_FireSystem
extends System

var accumulated_delta: float = 0.0
@export var delta_interval: float = 1.0

func query():
	return q.with_all([ZC_Effect_Burning])

func process(entities: Array[Entity], _components: Array, delta: float):
	# Run once per second
	accumulated_delta += delta
	if accumulated_delta < delta_interval:
		return

	for entity in entities:
		var burning := entity.get_component(ZC_Effect_Burning) as ZC_Effect_Burning
		burning.time_remaining -= accumulated_delta

		# Fire bypasses armor for now
		entity.add_relationship(RelationshipUtils.make_damage(burning.damage_per_second))

		if burning.time_remaining < 0:
			entity.remove_component(ZC_Effect_Burning)

	accumulated_delta = 0.0
