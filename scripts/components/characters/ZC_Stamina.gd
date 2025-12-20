extends Component
class_name ZC_Stamina

@export var current_stamina: float = 100.0:
	set(value):
		current_stamina = clampf(value, 0.0, max_stamina)

@export var max_stamina: float = 100.0

@export_group("Recharge")
@export var moving_recharge_rate: float = 0.1 # per second
@export var still_recharge_rate: float = 1.0
