extends Resource
class_name ZR_CampaignLevel

enum HintMode {
	APPEND,
	REPLACE,
}

@export var key: String
@export var title: String
@export var scene: PackedScene

@export_group("Loading")
@export var loading_hints: Array[String] = []
@export var loading_screen: Image = null
@export var hint_mode: HintMode = HintMode.APPEND
@export var min_load_time: float = 0.0
