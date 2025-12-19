extends Resource
class_name ZR_Attention_Score

enum AttentionEvent {
	HEARD,
	SAW,
}

@export var faction: String
@export var event: AttentionEvent
@export var score: float
@export var multiplier: float = 1.0
