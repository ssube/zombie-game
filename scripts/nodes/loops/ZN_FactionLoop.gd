extends ZN_BaseAction
## An action that loops over the characters in a faction.
class_name ZN_FactionLoop


@export var faction: StringName = &"hostile_zombies"


func _run(source: Node, event: Enums.ActionEvent, _actor: Node) -> void:
	var faction_entities := ECS.world.query.with_all([ZC_Faction]).execute()
	for entity in faction_entities:
		var faction_comp := entity.get_component(ZC_Faction) as ZC_Faction
		# TODO: move this filter to the query
		if faction_comp.faction_name != faction:
			continue

		super._run(source, event, entity)
