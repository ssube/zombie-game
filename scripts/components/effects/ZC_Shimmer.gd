extends Component
class_name ZC_Shimmer

@export var enabled: bool = false:
	set(value):
		var old_value := enabled
		enabled = value
		if old_value != enabled:
			property_changed.emit(self, "enabled", old_value, value)

@export var distance: float = 3.0

@export_group("Shimmer Settings")
@export var material: Material = null
@export var nodes: Array[NodePath] = []

@export_group("Triggers")
@export var on_target: bool = true
