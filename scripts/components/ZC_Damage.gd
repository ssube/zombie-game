extends Component
class_name ZC_Damage


@export var amount: float = 0.0
@export var source: String = ""

func _init(damage: float, from: String) -> void:
	amount = damage
	source = from
