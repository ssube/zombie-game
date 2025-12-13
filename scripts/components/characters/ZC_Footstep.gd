extends Component
class_name ZC_Footstep

@export var interval: float = 1.0
@export var variation: float = 0.1

@export var raycast: NodePath
@export var sounds: Dictionary[String, PackedScene] = {}
