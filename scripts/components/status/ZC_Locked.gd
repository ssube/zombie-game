extends Component
class_name ZC_Locked

@export var is_locked: bool = true:
	set(value):
		var previous_locked := is_locked
		is_locked = value
		property_changed.emit(self, "is_locked", previous_locked, is_locked)

@export var key_name: String
