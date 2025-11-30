extends Component
class_name ZC_Door

# TODO: auto-close timer
@export var open_on_touch: bool = false
@export var open_on_use: bool = true
@export var is_open: bool = false:
	set(value):
		var previous_open := is_open
		is_open = value
		property_changed.emit(self, "is_open", previous_open, is_open)

@export var is_locked: bool = false:
	set(value):
		var previous_locked := is_locked
		is_locked = value
		property_changed.emit(self, "is_locked", previous_locked, is_locked)

@export var key_name: String = ""

## Rotate both ways, away from the player
@export var rotate_away: bool = false
@export var open_rotation: Vector3 = Vector3.ZERO
@export var open_rotation_2: Vector3 = Vector3.ZERO
@export var close_rotation: Vector3 = Vector3.ZERO

@export var open_position: Vector3 = Vector3.ZERO
@export var close_position: Vector3 = Vector3.ZERO
