extends ZN_BaseAction
## Provides a point for attaching conditions
class_name ZN_BranchAction

var _actions: Array[ZN_BaseAction] = []

func _ready() -> void:
	super._ready()

	for child in self.get_children():
		if child is ZN_BaseAction:
			_actions.append(child)


func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	for action in _actions:
		action._run(source, event, actor)
