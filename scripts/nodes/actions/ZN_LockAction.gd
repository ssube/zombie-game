extends ZN_BaseAction
class_name ZN_LockAction

@export var target: Entity = null

@export var key_name: String = ""
@export var unlock: Enums.Tristate = Enums.Tristate.UNSET

func run_entity(_source: Node, _event: Enums.ActionEvent, _actor: Entity) -> void:
	var locked := target.get_component(ZC_Locked) as ZC_Locked
	if locked == null:
		return

	if key_name:
		locked.key_name = key_name

	match unlock:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			locked.is_locked = false
		Enums.Tristate.TRUE:
			locked.is_locked = true