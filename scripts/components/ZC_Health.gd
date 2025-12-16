extends Component
class_name ZC_Health

@export var max_health: int = 100
@export var current_health: int = 100:
	set(value):
		var last_health := current_health
		var new_health := clampi(value, 0, max_health)
		current_health = new_health
		if last_health != current_health:
			property_changed.emit(self, "current_health", last_health, current_health)

@export var hurt_sound: PackedScene
@export var death_sound: PackedScene

func _init(init_health: int = 100):
	max_health = init_health
	current_health = init_health
