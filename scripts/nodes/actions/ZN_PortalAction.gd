extends ZN_BaseAction
class_name ZN_PortalAction

@export var target: Entity = null

## Open the portal
@export var open: ZN_BaseAction.Tristate = ZN_BaseAction.Tristate.NO_CHANGE

## Use the portal
@export var activate: ZN_BaseAction.Tristate = ZN_BaseAction.Tristate.NO_CHANGE

func run(_actor: Entity) -> void:
	var portal := target.get_component(ZC_Portal) as ZC_Portal
	if portal == null:
		printerr("Target entity is not a portal: ", target)
		return

	match open:
		ZN_BaseAction.Tristate.NO_CHANGE:
			pass
		ZN_BaseAction.Tristate.SET_FALSE:
			portal.is_open = false
		ZN_BaseAction.Tristate.SET_TRUE:
			portal.is_open = true

	match activate:
		ZN_BaseAction.Tristate.NO_CHANGE:
			pass
		ZN_BaseAction.Tristate.SET_FALSE:
			portal.is_active = false
		ZN_BaseAction.Tristate.SET_TRUE:
			portal.is_active = true
