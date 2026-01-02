extends Component
class_name ZC_Light

@export var enabled: bool = true:
	set(value):
		var old_value = enabled
		enabled = value
		if old_value != value:
			property_changed.emit(self, "enabled", old_value, value)

@export var node_paths: Array[NodePath] = []
