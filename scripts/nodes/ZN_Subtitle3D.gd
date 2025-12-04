extends AudioStreamPlayer3D
class_name ZN_AudioSubtitle3D

@export_group("Flags")
@export var play_on_ready: bool = false
@export var play_on_loop: bool = false

@export_group("Subtitles")
@export var subtitle_text: String = ""
@export var subtitle_radius: float = 1.0

@onready var subtitle_tag = "[%s]" % subtitle_text
@onready var radius_squared := subtitle_radius ** 2

func _ready() -> void:
	if play_on_ready:
		play_subtitle()

	if play_on_loop:
		finished.connect(play_subtitle)

func play_subtitle(from_position: float = 0.0) -> void:
	if playing:
		super.stop()

	super.play(from_position)
