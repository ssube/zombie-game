extends Component
class_name ZC_Movement

@export_group("Movement")
@export var move_speed: float = 5.0
@export var move_acceleration: float = 2.0

@export_group("Look")
@export var look_speed: float = 5.0
@export var look_acceleration: float = 10.0

@export_group("Targets")
@export var has_look_target: bool = false
@export var target_look_position: Vector3 = Vector3.ZERO

@export var has_move_target: bool = false
@export var target_move_position: Vector3 = Vector3.ZERO

@export var target_proximity: float = 0.5

func _init() -> void:
	has_look_target = false
	has_move_target = false

func set_look_target(position: Vector3) -> void:
	has_look_target = true
	target_look_position = position

func clear_look_target() -> void:
	has_look_target = false

func set_move_target(position: Vector3) -> void:
	has_move_target = true
	target_move_position = position

func clear_move_target() -> void:
	has_move_target = false
