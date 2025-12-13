extends Component
class_name ZC_Noise

@export var audio_node: NodePath = "."
@export var sound_position: Vector3 = Vector3.ZERO
@export var sound_volume: float = 1.0
@export var subtitle_tag: String

static func from_node(node: ZN_AudioSubtitle3D) -> ZC_Noise:
	var noise := ZC_Noise.new()
	noise.audio_node = node.get_path()
	noise.sound_position = node.global_position
	noise.sound_volume = node.volume_linear
	noise.subtitle_tag = node.subtitle_tag
	return noise
