extends Component
class_name ZC_Shimmer

@export var enabled: bool = false
@export var material: Material = null
@export var nodes: Array[NodePath] = []

static func from_interactive(other: ZC_Interactive) -> ZC_Shimmer:
  var shimmer = ZC_Shimmer.new()
  shimmer.material = other.shimmer_material
  shimmer.nodes = other.shimmer_nodes
  return shimmer
