extends Component
class_name ZC_Perception

@export var active: bool = true

## Direct references updated by signal handlers (faster than searching stimuli)
@export var visible_entities: Dictionary[String, bool] = {}
