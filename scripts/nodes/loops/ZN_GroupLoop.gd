extends ZN_BaseAction
## An action that loops over a group of nodes.
class_name ZN_GroupLoop


@export var group_name: StringName


func _run(source: Node, event: Enums.ActionEvent, _actor: Node) -> void:
	var group_nodes := get_tree().get_nodes_in_group(group_name)
	for target in group_nodes:
		super._run(source, event, target)
