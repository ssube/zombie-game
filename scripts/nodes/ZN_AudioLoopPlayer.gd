extends AudioStreamPlayer
class_name ZN_AudioLoopPlayer

@export var loop_on_ready: bool = true
@export var max_loops: int = -1

var _loop_count: int = 0


func _ready() -> void:
	self.finished.connect(_loop)

	if loop_on_ready:
		self.play()


func _loop() -> void:
	if max_loops == -1:
		self.play()
		return

	_loop_count += 1
	if _loop_count >= max_loops:
		return

	self.play()
