extends Component
class_name ZC_Attention

@export var attention_events: Array[ZR_Attention_Score] = []

@export_group("State")
@export var attention_score: float = 0.0
@export var player_visible: bool = false
@export var heard_noise: bool = false
@export var last_known_player_position: Vector3 = Vector3.ZERO
# TODO: track target entity as well, maybe by ID