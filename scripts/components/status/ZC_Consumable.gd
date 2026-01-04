extends Component
class_name ZC_Consumable


@export var max_uses: int = 1
@export var current_uses: int = 1:
	set(value):
		current_uses = clamp(value, 0, max_uses)


func is_usable() -> bool:
	return current_uses > 0
