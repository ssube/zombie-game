extends Resource
class_name ZR_AudioOptions

@export var subtitles: bool = true

@export_group("Volume")
@export_range(0.0, 100.0) var main_volume: float = 25.0
@export_range(0.0, 100.0) var music_volume: float = 100.0
@export_range(0.0, 100.0) var effects_volume: float = 100.0
@export_range(0.0, 100.0) var menu_volume: float = 75.0
