extends ZN_BaseAction
class_name ZN_AreaAction

@export var area: ZN_TriggerArea3D = null
@export var active: Enums.Tristate = Enums.Tristate.UNSET

func run_entity(_source: Node, _event: Enums.ActionEvent, _actor: Entity) -> void:
	match active:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			area.active = false
		Enums.Tristate.TRUE:
			area.active = true
		# TODO: add toggle
