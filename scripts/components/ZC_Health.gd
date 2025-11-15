extends Component
class_name ZC_Health

@export var max_health: int = 100
@export var current_health: int = 100

func _init(init_health: int = 100):
    max_health = init_health
    current_health = init_health
