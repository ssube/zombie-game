extends ZN_TriggerTimer
class_name ZN_VariableTriggerTimer

@export var min_variation: float = -1.0
@export var max_variation: float = 1.0

# @onready var _default_wait_time := self.wait_time

func _ready() -> void:
	self.one_shot = not repeat
	timeout.connect(on_timeout)

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)

	if self.start_on_ready:
		self.start_variable(self.wait_time)


func start_variable(time_sec: float) -> void:
	var offset := randf_range(min_variation, max_variation)
	self.start(time_sec + offset)
