extends Component
class_name ZC_Skin

@export_group("Materials")
@export var material_healthy: BaseMaterial3D = null
@export var material_injured: BaseMaterial3D = null
@export var material_dead: BaseMaterial3D = null

@export_group("Nodes")
@export var skin_shapes: Array[NodePath] = []
