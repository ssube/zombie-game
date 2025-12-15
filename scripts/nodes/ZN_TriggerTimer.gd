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
	# TODO: send some real parameters
	apply_actions(self, null, ZN_TriggerArea3D.AreaEvent.TIMER_TIMEOUT)


func apply_actions(body: Node, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	for action in _actions:
		action._run(body, area, event)
