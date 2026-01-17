extends Resource
class_name ZR_Campaign

@export var title: String = "Zombie Game"
@export var title_image: Texture2D
@export var title_scene: PackedScene

@export var levels: Array[ZR_CampaignLevel] = []
@export var loading_image: Texture2D
@export var loading_hints: Array[String] = [
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

func merge_campaign(other: ZR_Campaign) -> ZR_Campaign:
	var level_keys := []
	for level in self.levels:
		level_keys.append(level.key)

	for level in other.levels:
		if level_keys.has(level.key):
			ZombieLogger.warning("Campaign {0} is replacing level {1}!", [other.title, level.key])

	self.loading_hints.append_array(other.loading_hints)
	self.levels.append_array(other.levels)
	self.title = "%s (merged with %s)" % [self.title, other.title]

	return self
