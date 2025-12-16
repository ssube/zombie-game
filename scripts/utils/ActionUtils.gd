class_name ActionUtils


static func run_component(component: ZC_Action, actor: Node, parent: Node, event: ZN_TriggerArea3D.AreaEvent) -> void:
	if event not in component.actions:
		return

	var action_path := component.actions[event]
	var action_node := parent.get_node(action_path)
	if not action_node:
		return

	ActionUtils.run_node(action_node, actor, parent, event)


static func run_node(node: Node, actor: Node, parent: Node, event: ZN_TriggerArea3D.AreaEvent) -> void:
	# actions are responsible for running their own children
	if node is ZN_BaseAction:
		node._run(actor, parent, event)
		return

	# otherwise, run any children that are actions
	for child in node.get_children():
		if child is ZN_BaseAction:
			child._run(actor, parent, event)
