extends Component
class_name ZC_Interactive

@export var name: String = "Interactive Object"

@export_group("Shimmer")
@export_subgroup("Shimmer Flags")
@export var shimmer_on_proximity: bool = false
@export var shimmer_on_target: bool = true

@export_subgroup("Shimmer Parameters")
@export var shimmer_range: float = 5.0
@export var shimmer_material: Material = null
@export var shimmer_nodes: Array[NodePath] = []

@export_group("Sounds")
@export var pickup_sound: PackedScene
@export var use_sound: PackedScene