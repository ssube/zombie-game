extends ZN_BaseCondition
class_name ZN_FactionCondition

static var world_faction := &"world"

# TODO: support wildcards (with performance testing)
@export var apply_to_factions: Array[String] = []


func test(actor: Node, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> bool:
	if actor is not Entity:
		return false

	var actor_faction := actor.get_component(ZC_Faction) as ZC_Faction
	if actor_faction == null:
		return world_faction in apply_to_factions

	return actor_faction.faction_name in apply_to_factions
