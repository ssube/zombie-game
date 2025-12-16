extends ZN_BaseAction
class_name ZN_AudioAction

@export var audio_player: AudioStreamPlayer3D

func run_node(_node: Node, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	if audio_player is ZN_AudioSubtitle3D:
		audio_player.play_subtitle()
	else:
		audio_player.play()
