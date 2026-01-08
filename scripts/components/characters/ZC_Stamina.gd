extends Component
class_name ZC_Stamina

@export var current_stamina: float = 100.0:
	set(value):
		current_stamina = clampf(value, 0.0, max_stamina)

@export var max_stamina: float = 100.0

@export_group("Cost")
@export var cost_enabled: bool = true
@export var velocity_multiplier: float = 0.1
@export var jump_cost: float = 25.0
@export var sprint_multiplier: float = 2.0
@export var hill_multiplier: float = 3.0

@export_group("Limits")
@export var jump_limit: float = 25.0
@export var sprint_limit: float = 10.0

@export_group("Recharge")
@export var recharge_enabled: bool = true
@export var moving_recharge_rate: float = 0.1 # per second
@export var still_recharge_rate: float = 1.0

func can_jump() -> bool:
	return current_stamina > jump_limit

func can_sprint() -> bool:
	return current_stamina > sprint_limit
