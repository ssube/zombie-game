extends ZN_BaseAction
class_name ZN_AnimationAction

@export var animation_player: AnimationPlayer
@export var event_animations: Dictionary[Enums.ActionEvent, String] = {}

func run_node(_source: Node, event: Enums.ActionEvent, _actor: Node) -> void:
	if event in event_animations:
		var animation := event_animations[event]
		animation_player.play(animation)
