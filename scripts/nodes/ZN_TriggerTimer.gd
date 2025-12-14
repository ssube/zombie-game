extends Timer
class_name ZN_TriggerTimer

var _actions: Array[ZN_BaseAction] = []

func _ready() -> void:
	timeout.connect(on_timeout)

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)


func on_timeout() -> void:
	# TODO: send some real parameters
	apply_actions(self, null, ZN_TriggerArea3D.AreaEvent.TIMER_TIMEOUT)


func apply_actions(body: Node, area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	for action in _actions:
		action._run(body, area, event)
