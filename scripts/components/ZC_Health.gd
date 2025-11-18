extends Component
class_name ZC_Health

@export var max_health: int = 100
@export var current_health: int = 100:
    set(value):
        property_changed.emit(self, "current_health", current_health, value)
        current_health = value

func _init(init_health: int = 100):
    max_health = init_health
    current_health = init_health

