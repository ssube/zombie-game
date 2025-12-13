extends Resource
class_name GameOptions

@export_group("Gameplay")
@export var physical_casings: bool = true
@export var physical_mags: bool = true

@export_group("Graphics")
@export var crt_shader: bool = true
@export var screen_resolution: Vector2i = Vector2i(640, 480)

@export_group("Audio")
@export_range(0.0, 100.0) var main_volume: float = 50.0
@export_range(0.0, 100.0) var music_volume: float = 50.0
@export_range(0.0, 100.0) var effects_volume: float = 50.0
@export var subtitles: bool = true


static func load_path(path: String = "user://options.tres") -> GameOptions:
	if not ResourceLoader.exists(path):
		return GameOptions.new()

	var options := ResourceLoader.load(path, "GameOptions") as GameOptions
	return options

func save_path(path: String = "user://options.tres") -> bool:
	var error := ResourceSaver.save(self, path)
	if error != OK:
		printerr("Error saving options: ", error)
		return false

	return true
