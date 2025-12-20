extends Resource
class_name ZR_Campaign

@export var title: String = "Zombie Game"
@export var levels: Array[ZR_CampaignLevel] = []
@export var hints: Array[String] = [
	"Zombies are bad for your health.",
	"Zombies are usually green.",
	"Zombies do not like being shot in the head.",
]

var _level_keys: Dictionary[String, ZR_CampaignLevel] = {}

func cache() -> void:
	for level in levels:
		_level_keys[level.key] = level

func has_level(key: String) -> bool:
	return key in _level_keys

func get_level(key: String) -> ZR_CampaignLevel:
	return _level_keys.get(key, null) as ZR_CampaignLevel
