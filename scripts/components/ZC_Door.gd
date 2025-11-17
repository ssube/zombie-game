extends Component
class_name ZC_Door

# TODO: auto-close timer
@export var open_on_touch: bool = false
@export var open_on_use: bool = true
@export var is_open: bool = false
@export var is_locked: bool = false
@export var key_name: String = ""

## Rotate both ways, away from the player
@export var rotate_away: bool = false
@export var open_rotation: Vector3 = Vector3.ZERO
@export var open_rotation_2: Vector3 = Vector3.ZERO
@export var close_rotation: Vector3 = Vector3.ZERO

@export var open_position: Vector3 = Vector3.ZERO
@export var close_position: Vector3 = Vector3.ZERO
