extends ZN_BaseAction
class_name ZN_AreaAction

@export var area: ZN_TriggerArea3D = null
@export var active: ZN_BaseAction.Tristate = ZN_BaseAction.Tristate.NO_CHANGE


func run(_actor: Entity, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	match active:
		ZN_BaseAction.Tristate.NO_CHANGE:
			pass
		ZN_BaseAction.Tristate.SET_FALSE:
			area.active = false
		ZN_BaseAction.Tristate.SET_TRUE:
			area.active = true
		# TODO: add toggle
