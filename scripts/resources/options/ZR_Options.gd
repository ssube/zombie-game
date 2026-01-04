extends Resource
class_name ZR_Options

@export var audio: ZR_AudioOptions = ZR_AudioOptions.new()
@export var controls: ZR_ControlOptions = ZR_ControlOptions.new()
@export var cheats: ZR_CheatOptions = ZR_CheatOptions.new()
@export var gameplay: ZR_GameplayOptions = ZR_GameplayOptions.new()
@export var graphics: ZR_GraphicsOptions = ZR_GraphicsOptions.new()

static func load_path(path: String = "user://options.tres") -> ZR_Options:
	if not ResourceLoader.exists(path):
		return ZR_Options.new()

	var options := ResourceLoader.load(path, "ZR_Options") as ZR_Options
	return options

func save_path(path: String = "user://options.tres") -> bool:
	var error := ResourceSaver.save(self, path)
	if error != OK:
		ZombieLogger.error("Error saving options: {0}", [error])
		return false

	return true
