extends ZN_BaseAction
class_name ZN_DoorAction

@export var target: Entity = null

# @export var unlock: Enums.Tristate = Enums.Tristate.UNSET
@export var open: Enums.Tristate = Enums.Tristate.UNSET

func run_entity(_source: Node, _event: Enums.ActionEvent, _actor: Entity) -> void:
	var door := target.get_component(ZC_Door) as ZC_Door
	if door == null:
		ZombieLogger.warning("Target is not a door: {0}", [target.get_path()])
		return

	# TODO: should open actions run if the door is locked?
	var locked := target.get_component(ZC_Locked) as ZC_Locked
	if locked and locked.is_locked:
		return

	match open:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			door.is_open = false
		Enums.Tristate.TRUE:
			door.is_open = true
