class_name ActionUtils


static func run_component(component: ZC_Action, source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	if event not in component.actions:
		return

	var action_path := component.actions[event]
	var action_node := source.get_node(action_path)
	if not action_node:
		return

	ActionUtils.run_node(action_node, source, event, actor)


static func run_node(node: Node, source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	# actions are responsible for running their own children
	if node is ZN_BaseAction:
		node._run(source, event, actor)
		return

	# otherwise, run any children that are actions
	for child in node.get_children():
		if child is ZN_BaseAction:
			child._run(source, event, actor)
