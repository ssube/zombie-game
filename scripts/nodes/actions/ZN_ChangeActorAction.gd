extends ZN_BranchAction
class_name ZN_ChangeActorAction

@export var set_actor_to_source: bool = true
@export var set_actor: Entity

func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	var inner_actor = actor
	if set_actor_to_source:
		inner_actor = source

	if set_actor:
		inner_actor = set_actor

	for action in _actions:
		action._run(source, event, inner_actor)
