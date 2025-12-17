extends ZN_BaseAction
class_name ZN_TimerAction

@export var start: bool = true
@export var timer: Timer = null

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	if start:
		timer.start()
