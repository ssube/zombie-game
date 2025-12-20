extends Component
class_name ZC_Screen_Effect

@export var effect: ZM_BaseMenu.Effects
@export var duration: float = 1.0
@export var strength: float = 1.0
@export var total_duration: float = 1.0
@export var strength_curve: Curve

func duration_ratio() -> float:
	return duration / total_duration

func current_strength() -> float:
	if not strength_curve:
		return strength

	var ratio := duration_ratio()
	return strength_curve.sample(ratio)

func _init() -> void:
	# TODO: ends up using a lower value, usually the default
	total_duration = duration
