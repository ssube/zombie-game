extends Timer
class_name ZN_TriggerTimer


@export var start_on_ready: bool = true
@export var repeat: bool = false


var _actions: Array[ZN_BaseAction] = []

func _ready() -> void:
	self.one_shot = not repeat
	timeout.connect(on_timeout)

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)

	if start_on_ready:
		self.start()


func on_timeout() -> void:
	apply_actions(self, Enums.ActionEvent.TIMER_TIMEOUT, null)


func apply_actions(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	for action in _actions:
		action._run(source, event, actor)
