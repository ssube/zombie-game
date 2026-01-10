extends ZN_BaseAction
class_name ZN_LadderAction

## Enables ladder climbing mode when an actor enters the trigger area.
## The actor must be a ZE_Player_IKCC for this action to have any effect.

## If true, automatically enable ladder mode on enter and disable on exit.
@export var toggle_on_trigger: bool = true

func run_node(_source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	if actor is not ZE_Player_IKCC:
		return

	match event:
		Enums.ActionEvent.BODY_ENTER:
			if toggle_on_trigger:
				actor.is_on_ladder = true
		Enums.ActionEvent.BODY_EXIT:
			if toggle_on_trigger:
				actor.is_on_ladder = false
