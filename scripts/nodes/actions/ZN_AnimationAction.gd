extends ZN_BaseAction
class_name ZN_AnimationAction

@export var animation_player: AnimationPlayer
@export var event_animations: Dictionary[ZN_TriggerArea3D.AreaEvent, String] = {}

func run_node(_node: Node, _area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	if event in event_animations:
		var animation := event_animations[event]
		animation_player.play(animation)
