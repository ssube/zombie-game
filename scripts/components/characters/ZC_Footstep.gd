extends Component
class_name ZC_Footstep

@export var crouch_interval: float = 2.0
@export var walk_interval: float = 1.0
@export var sprint_interval: float = 0.25
@export var variation: float = 0.1

@export var raycast: NodePath
@export var sounds: Dictionary[String, PackedScene] = {}
