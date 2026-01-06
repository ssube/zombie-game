extends Component
class_name ZC_Inventory


@export_group("Nodes")
## The node path to this entity's ZN_Inventory node
@export var node_path: NodePath = "Inventory"
## The node path to the marker where items should be dropped
@export var drop_marker: NodePath = "Inventory/DropMarker"

@export_group("Limits")
## The maximum number of item slots in the inventory
@export var max_slots: int = 20
#@export var max_weight: float = 50.0
#@export var max_stack_size: int = 10

@export_group("State")
## The IDs of items currently in the inventory
@export var item_ids: Dictionary[String, bool] = {}