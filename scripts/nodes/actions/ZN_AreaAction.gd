extends ZN_BaseAction
class_name ZN_AreaAction

@export var area: Area3D = null
@export var active: Enums.Tristate = Enums.Tristate.UNSET

func run_entity(_source: Node, _event: Enums.ActionEvent, _actor: Entity) -> void:
	match active:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			area.monitoring = false
			if area is ZN_TriggerArea3D:
				area.active = false
		Enums.Tristate.TRUE:
			area.monitoring = true
			if area is ZN_TriggerArea3D:
				area.active = true
		# TODO: add toggle
