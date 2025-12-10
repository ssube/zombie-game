extends Component
class_name ZC_Door

@export var open_on_proximity: bool = false
@export var open_on_touch: bool = false
@export var open_on_use: bool = true

@export var is_open: bool = false:
	set(value):
		var previous_open := is_open
		is_open = value
		property_changed.emit(self, "is_open", previous_open, is_open)

## Rotate both ways, away from the player
@export var rotate_away: bool = false

@export var open_marker: NodePath
@export var open_marker_away: NodePath
@export var close_marker: NodePath

@export var open_time: float = 1.0
@export var close_time: float = 1.0
@export var auto_close_time: float = 0.0

@export var open_area: NodePath
