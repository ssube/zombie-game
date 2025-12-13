extends AudioStreamPlayer3D
class_name ZN_AudioSubtitle3D

@export_group("Flags")
@export var play_on_ready: bool = false
@export var play_on_loop: bool = false

@export_group("Subtitles")
@export var subtitle_text: String = ""
@export var subtitle_radius: float = 1.0

@export_group("Removal")
@export var remove_after: float = 0.0
@export var remove_on_finished: bool = true

@onready var subtitle_tag = "[%s]" % subtitle_text
@onready var radius_squared := subtitle_radius ** 2
var remove_timer: SceneTreeTimer

func _ready() -> void:
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

	# TODO: add sound to enemies too
	var players := EntityUtils.get_players()
	for player in players:
		var player3d := player.get_node(".") as Node3D
		if player3d.global_position.distance_squared_to(self.global_position) < radius_squared:
			var noise := ZC_Noise.from_node(self)
			player.add_relationship(RelationshipUtils.make_heard(noise))

	super.play(from_position)
