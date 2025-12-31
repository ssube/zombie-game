extends ZN_BaseAction
class_name ZN_BuoyancyAction

@export var toggle_in_trigger: bool = true

func run_node(_source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	if actor is not ZN_Buoyant:
		return

	match event:
		Enums.ActionEvent.BODY_ENTER:
			if toggle_in_trigger:
				actor.active = true
		Enums.ActionEvent.BODY_EXIT:
			if toggle_in_trigger:
				actor.active = false
