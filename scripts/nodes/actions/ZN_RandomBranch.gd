extends ZN_BranchAction
class_name ZN_RandomBranch

func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	var value := randi_range(0, _actions.size() - 1)
	_actions[value]._run(source, event, actor)
