extends ZN_BaseCondition
class_name ZN_EventCondition

@export var allow_events: Array[Enums.ActionEvent] = []

func test(_source: Node, event: Enums.ActionEvent, _actor: Node) -> bool:
	if event in allow_events:
		return true

	return false
