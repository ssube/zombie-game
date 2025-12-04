extends Component
class_name ZC_Noise

@export var audio_node: NodePath = "."

static func from_node(node: ZN_AudioSubtitle3D) -> ZC_Noise:
	var noise := ZC_Noise.new()
	noise.audio_node = node.get_path()
	return noise
