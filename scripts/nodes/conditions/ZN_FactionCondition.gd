extends ZN_BaseCondition
class_name ZN_FactionCondition

# TODO: turn into a component later
enum Factions {
	NONE = 0,
	ENEMY = 1,
	PLAYER = 2,
	SURVIVOR = 4,
}

@export_flags("Enemy:1", "Player:2", "Survivor:4") var apply_to_factions: Array[int] = []

func test(actor: Entity, _area, _event) -> bool:
	if Factions.ENEMY in apply_to_factions:
		if EntityUtils.is_enemy(actor):
			return true

	if Factions.PLAYER in apply_to_factions:
		if EntityUtils.is_player(actor):
			return true

	if Factions.SURVIVOR in apply_to_factions:
		assert(false, "TODO: implement survivor faction!")

	return false