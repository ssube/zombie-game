extends Component
class_name ZC_Effect_Burning


@export var damage_per_second: int = 10
@export var time_remaining: float = 5.0

func _init(duration: float = 5.0) -> void:
	time_remaining = duration
