extends Component
class_name ZC_Health

@export var max_health: int = 100
@export var current_health: int = 100:
	set(value):
		var last_health := current_health
		current_health = value
		property_changed.emit(self, "current_health", last_health, current_health)

func _init(init_health: int = 100):
	max_health = init_health
	current_health = init_health
