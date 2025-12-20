extends System
class_name ZS_EffectSystem


func deps() -> Dictionary[int, Array]:
	return {
		Runs.Before: [ZS_PlayerSystem],
	}


func query() -> QueryBuilder:
	return q.with_all([ZC_Player]).with_relationship([RelationshipUtils.any_effect])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var effects := entity.get_relationships(RelationshipUtils.any_effect) as Array[Relationship]
		for rel in effects:
			var effect := rel.target as ZC_Screen_Effect
			effect.duration -= delta
			if effect.duration <= 0.0:
				entity.remove_relationship(rel)
