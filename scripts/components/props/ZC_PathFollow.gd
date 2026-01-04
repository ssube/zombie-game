extends Component
class_name ZC_PathFollow

@export var path: NodePath
@export var active: bool = false
@export var loop: bool = false
@export var duration: float = 1.0
@export_range(0.0, 1.0, 0.01) var offset: float = 0.0

@export_group("Look Ahead")
@export var look_ahead: bool = false
@export var look_ahead_distance: float = 1.0

@export_group("State")
@export var elapsed_time: float = 0.0

# @export var speed: float = 1.0
# @export var start_timer: NodePath
# @export var resume_timer: NodePath
# @export var stop_timer: NodePath
# @export var speed_curve: Curve
