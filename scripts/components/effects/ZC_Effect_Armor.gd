extends Component
class_name ZC_Effect_Armor

## Lower = more armor, less damage. Higher = less armor, more damage.
## Values > 1 will increase damage rather than reduce it.
@export_range(0.0, 4.0, 0.1) var multiplier: float = 1.0

func _init(value: float = 0.0) -> void:
  multiplier = value
