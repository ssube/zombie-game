extends ZN_BaseAction
class_name ZN_CallAction

@export var target_actions: Array[ZN_BaseAction] = []

func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	for action in target_actions:
		action._run(source, event, actor)
