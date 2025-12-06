extends ZN_BaseAction
class_name ZN_DoorAction

@export var target: Entity = null

@export var unlock: Tristate = Tristate.NO_CHANGE
@export var open: Tristate = Tristate.NO_CHANGE

func run(_actor: Entity) -> void:
	var door := target.get_component(ZC_Door) as ZC_Door
	if door == null:
		printerr("Target is not a door: ", target)
		return

	match unlock:
		Tristate.NO_CHANGE:
			pass
		Tristate.SET_FALSE:
			door.is_locked = false
		Tristate.SET_TRUE:
			door.is_locked = true

	match open:
		Tristate.NO_CHANGE:
			pass
		Tristate.SET_FALSE:
			door.is_open = false
		Tristate.SET_TRUE:
			door.is_open = true
