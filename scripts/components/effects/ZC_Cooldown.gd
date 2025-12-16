extends Component
class_name ZC_Cooldown

@export var time_remaining: float = 0.0

func _init(time: float = 0.0):
	assert(time > 0, "Cooldown time should be > 0!")
	time_remaining = time
