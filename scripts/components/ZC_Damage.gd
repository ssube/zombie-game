extends Component
class_name ZC_Damage


@export var amount: float = 0.0
@export var source: Resource = null

func _init(damage: float = 0.0) -> void:
  amount = damage