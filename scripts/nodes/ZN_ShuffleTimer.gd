extends ZN_TriggerTimer
class_name ZN_ShuffleTimer

@export var times: Array[float] = []
@export var shuffle_on_start: bool = true

var _current_index: int = 0


func _ready():
	if shuffle_on_start:
		times.shuffle()
	_current_index = 0
	super._ready()


func on_timeout() -> void:
	super.on_timeout()
	_current_index += 1
	if _current_index >= times.size():
		if repeat:
			_current_index = 0
			if shuffle_on_start:
				times.shuffle()
		else:
			return

	self.start(times[_current_index])


func start_shuffle() -> void:
	_current_index = 0
	self.start(times[_current_index])
