extends ZN_BaseAction
class_name ZN_AudioAction

@export var audio_player: AudioStreamPlayer3D

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	if audio_player is ZN_AudioSubtitle3D:
		audio_player.play_subtitle()
	else:
		audio_player.play()
