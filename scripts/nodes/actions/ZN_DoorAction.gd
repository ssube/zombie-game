extends ZN_BaseAction
class_name ZN_DoorAction

@export var target: Entity = null

@export var unlock: Tristate = Tristate.NO_CHANGE
@export var open: Tristate = Tristate.NO_CHANGE

func run_entity(_actor: Entity, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	var door := target.get_component(ZC_Door) as ZC_Door
	if door == null:
		printerr("Target is not a door: ", target)
		return

	match open:
		Tristate.NO_CHANGE:
			pass
		Tristate.SET_FALSE:
			door.is_open = false
		Tristate.SET_TRUE:
			door.is_open = true

	var locked := target.get_component(ZC_Locked) as ZC_Locked
	if locked == null:
		return

	match unlock:
		Tristate.NO_CHANGE:
			pass
		Tristate.SET_FALSE:
			locked.is_locked = false
		Tristate.SET_TRUE:
			locked.is_locked = true
