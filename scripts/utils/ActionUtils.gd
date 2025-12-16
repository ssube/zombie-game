class_name ActionUtils


static func run_component(component: ZC_Action, source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	if event not in component.actions:
		return

	var action_path := component.actions[event]
	var action_node := source.get_node(action_path)
	if not action_node:
		return

	ActionUtils.run_node(action_node, source, event, actor)


# TODO: should this have a source parameter or will that always be the entity?
static func run_entity(entity: Entity, event: Enums.ActionEvent, actor: Node) -> void:
	var actions := entity.get_component(ZC_Action) as ZC_Action
	if actions:
		ActionUtils.run_component(actions, entity, event, actor)

	var extra_actions := entity.get_component(ZC_ExtraAction) as ZC_ExtraAction
	if extra_actions:
		ActionUtils.run_component(extra_actions, entity, event, actor)


static func run_node(node: Node, source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	# actions are responsible for running their own children
	if node is ZN_BaseAction:
		node._run(source, event, actor)
		return

	# otherwise, run any children that are actions
	for child in node.get_children():
		if child is ZN_BaseAction:
			child._run(source, event, actor)
