extends ZN_BaseCondition
class_name ZN_FactionCondition

# TODO: turn into a component later
enum Factions {
	NONE = 0,
	ENEMY = 1,
	PLAYER = 2,
	SURVIVOR = 4,
}

@export_flags("Enemy:1", "Player:2", "Survivor:4") var apply_to_factions: Factions = Factions.NONE

func test(actor: Entity, _area, _event) -> bool:
	if apply_to_factions & Factions.ENEMY:
		if EntityUtils.is_enemy(actor):
			return true

	if apply_to_factions & Factions.PLAYER:
		if EntityUtils.is_player(actor):
			return true

	# TODO: implement
	# if apply_to_factions & Factions.SURVIVOR:

	return false