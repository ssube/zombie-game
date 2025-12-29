extends Button
class_name AudioButton


@export var audio_stream: AudioStreamPlayer


func _ready() -> void:
	pressed.connect(_pressed)


func _pressed() -> void:
	if audio_stream != null:
		audio_stream.play()
