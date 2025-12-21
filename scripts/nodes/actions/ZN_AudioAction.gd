extends ZN_BaseAction
class_name ZN_AudioAction

enum AudioMode {
	ALL,
	RANDOM,
}

@export var audio_mode: AudioMode = AudioMode.ALL
@export var audio_players: Array[AudioStreamPlayer3D] = []

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	for audio_player in audio_players:
		if audio_player is ZN_AudioSubtitle3D:
			audio_player.play_subtitle()
		else:
			audio_player.play()
