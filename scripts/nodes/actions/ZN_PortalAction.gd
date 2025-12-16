extends ZN_BaseAction
class_name ZN_PortalAction

@export var target: Entity = null

## Open the portal
@export var open: Enums.Tristate = Enums.Tristate.UNSET

## Use the portal
@export var activate: Enums.Tristate = Enums.Tristate.UNSET

func run_entity(_source: Node, _event: Enums.ActionEvent, _actor: Entity) -> void:
	var portal := target.get_component(ZC_Portal) as ZC_Portal
	if portal == null:
		printerr("Target entity is not a portal: ", target)
		return

	match open:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			portal.is_open = false
		Enums.Tristate.TRUE:
			portal.is_open = true

	match activate:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			portal.is_active = false
		Enums.Tristate.TRUE:
			portal.is_active = true
