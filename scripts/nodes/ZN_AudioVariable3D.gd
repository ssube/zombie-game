extends ZN_AudioSubtitle3D
class_name ZN_AudioVariable3D

@export_group("Pitch Variation")
@export var pitch_variation_enabled: bool = true
@export var pitch_variation_min: float = 0.8
@export var pitch_variation_max: float = 1.25

@export_group("Volume Variation")
@export var volume_variation_enabled: bool = true
@export var volume_variation_min: float = 0.9
@export var volume_variation_max: float = 1.1


@onready var _original_pitch_scale := self.pitch_scale
@onready var _original_volume_linear := self.volume_linear


func play_subtitle(from_position: float = 0.0) -> void:
	if pitch_variation_enabled:
		self.pitch_scale = _original_pitch_scale * randf_range(pitch_variation_min, pitch_variation_max)

	if volume_variation_enabled:
		self.volume_linear = _original_volume_linear * randf_range(volume_variation_min, volume_variation_max)

	super.play_subtitle(from_position)