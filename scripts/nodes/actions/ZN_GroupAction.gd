extends ZN_BranchAction
class_name ZN_GroupAction

@export var groups: Array[String] = []

func run_node(source: Node, event: Enums.ActionEvent, _actor: Node) -> void:
	for group in groups:
		var nodes := get_tree().get_nodes_in_group(group)
		for node in nodes:
			super.run_node(source, event, node)
