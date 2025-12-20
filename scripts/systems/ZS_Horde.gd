extends System
class_name ZS_HordeSystem

## Run this less frequently (every 0.5s) for performance
@export var update_interval := 0.5

var _update_timer: float = 0.0


func _should_process(delta: float) -> bool:
		_update_timer += delta
		if _update_timer >= update_interval:
			_update_timer = 0.0
			return true

		return false


func deps() -> Dictionary[int, Array]:
	return {
		Runs.After: [ZS_AttentionSystem],
	}


func query() -> QueryBuilder:
		return q.with_all([ZC_Perception, ZC_Faction])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	if not _should_process(delta):
		return

	for entity in entities:
		var perception := entity.get_component(ZC_Perception) as ZC_Perception

		# Check visible entities for aggressive allies
		for visible_id in perception.visible_entities.keys():
			var visible := ECS.world.get_entity_by_id(visible_id)
			if visible == null:
				continue

			var faction := entity.get_component(ZC_Faction) as ZC_Faction
			var other_faction = visible.get_component(ZC_Faction) as ZC_Faction
			if other_faction == null or other_faction.faction_name != faction.faction_name:
				continue

			var other_attention = visible.get_component(ZC_Attention) as ZC_Attention
			if other_attention == null:
				continue

			# If ally is highly aggressive (in combat), create stimulus
			if other_attention.score > 0.7:
				var stimulus := ZC_Stimulus.saw_aggressive_ally(visible, other_attention.target_position, other_attention.score)
				entity.add_relationship(RelationshipUtils.make_detected(stimulus))
