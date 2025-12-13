extends Component
class_name ZC_Movement

@export_group("Movement")
@export var move_speed: float = 5.0
@export var move_acceleration: float = 2.0

@export_group("Look")
@export var look_speed: float = 5.0
@export var look_acceleration: float = 10.0

@export_group("Targets")
@export var target_look_position: Vector3 = Vector3.ZERO
@export var target_move_position: Vector3 = Vector3.ZERO
@export var target_proximity: float = 0.5