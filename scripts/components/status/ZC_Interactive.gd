extends Component
class_name ZC_Interactive

enum CrosshairType {
	NONE,
	DEFAULT,
	INTERACT,
	ATTACK
}

@export var name: String = "Interactive Object"
@export var pickup: bool = true

@export_group("Crosshair")
@export var show_crosshair: bool = true
@export var crosshair_type: CrosshairType = CrosshairType.DEFAULT:
	get():
		if show_crosshair:
			return crosshair_type
		else:
			return CrosshairType.NONE

@export var crosshair_color: Color = Color.WHITE:
	get():
		if show_crosshair:
			return crosshair_color
		else:
			return Color.TRANSPARENT

# TODO: custom crosshair icon
# @export var crosshair_icon: Texture2D

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
