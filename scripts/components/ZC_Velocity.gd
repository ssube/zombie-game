extends Component
class_name ZC_Velocity

@export var gravity := Vector3.DOWN * 9.8
@export var linear_velocity: Vector3 = Vector3.ZERO
@export var speed_multiplier: float = 1.0

func _init(vel: Vector3 = Vector3.ZERO):
	linear_velocity = vel
