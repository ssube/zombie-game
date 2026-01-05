extends Component
class_name ZC_Inventory


@export var node_path: NodePath = "Inventory"
@export var item_ids: Dictionary[String, bool] = {}

@export_group("Limits")
@export var max_slots: int = 20
#@export var max_weight: float = 50.0
#@export var max_stack_size: int = 10
