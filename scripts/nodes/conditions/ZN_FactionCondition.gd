extends ZN_BaseCondition
class_name ZN_FactionCondition

# TODO: support wildcards (with performance testing)
@export var apply_to_factions: Array[String] = []


func test(_source: Node, _event: Enums.ActionEvent, actor: Node) -> bool:
	if actor is not Entity:
		return false

	var actor_faction := actor.get_component(ZC_Faction) as ZC_Faction
	if actor_faction == null:
		return Constants.FACTION_WORLD in apply_to_factions

	return actor_faction.faction_name in apply_to_factions
