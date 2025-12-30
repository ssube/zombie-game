extends AudioStreamPlayer3D
class_name ZN_AudioSubtitle3D

@export_group("Flags")
@export var play_on_ready: bool = false
@export var play_on_loop: bool = false

@export_group("Attention")
@export var sound_radius: float = 10.0
@export var sound_volume: float = 1.0
@export var sound_faction: StringName = &"object"
## If true, this sound will alert zombies (not just show subtitles)
@export var alerts_enemies: bool = true

@export_group("Subtitles")
@export var subtitle_text: String = ""
@export var subtitle_radius: float = 1.0

@export_group("Removal")
@export var remove_after: float = 0.0
@export var remove_on_finished: bool = true

@onready var radius_squared := subtitle_radius ** 2

var subtitle_tag := ""
var remove_timer: SceneTreeTimer

func _ready() -> void:
	if subtitle_text == "":
		if subtitle_radius > 0.0:
			push_warning("ZN_AudioSubtitle3D has empty subtitle text and positive subtitle radius!")
	else:
		subtitle_tag = "[%s]" % subtitle_text

	if play_on_ready:
		play_subtitle()

	if play_on_loop:
		finished.connect(play_subtitle)

	if remove_after > 0:
		remove_timer = get_tree().create_timer(remove_after)
		remove_timer.timeout.connect(_remove)

	if remove_on_finished:
		assert(play_on_loop == false, "Remove-on-finished and play-on-loop do not make sense together!")
		finished.connect(_remove)

func _remove() -> void:
	self.stop()
	self.queue_free()

func play_subtitle(from_position: float = 0.0) -> void:
	if playing:
		self.stop()

	if alerts_enemies:
		# Find the source entity if this sound is attached to one
		# TODO: this is the wrong call to use here
		var source_entity: Entity = CollisionUtils.get_collider_entity(self)

		# Full broadcast: subtitles + zombie attention
		SoundUtils.broadcast(
				self.global_position,
				sound_radius,
				sound_volume,
				subtitle_tag,
				sound_faction,
				source_entity
		)
	else:
		if OptionsManager.options.audio.subtitles:
			# Subtitle-only broadcast (for UI sounds, ambient, etc.)
			SoundUtils.broadcast(
					self.global_position,
					sound_radius,
					sound_volume,
					subtitle_tag,
					&"",  # Empty faction = no attention
					null
			)

	super.play(from_position)
