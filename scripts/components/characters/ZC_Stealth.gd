extends Component
class_name ZC_Stealth

@export var visibility_level: float = 1.0 # 1.0 = fully visible, 0.0 = fully hidden
@export var visibility_threshold: float = 0.1
@export var is_hiding: bool = false

func is_hidden() -> bool:
	return (visibility_level < visibility_threshold)
