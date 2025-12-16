extends ZN_BaseAction
class_name ZN_NodeAction

@export var node: Node = null
@export var remove: bool = false


func _get_target(other: Node) -> Entity:
	if node:
		return node

	return other


func _remove_node(target: Node) -> void:
	var parent := target.get_parent()
	if parent:
		parent.remove_child(target)

	target.queue_free()


func run_node(_source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	var target := _get_target(actor)

	if remove:
		_remove_node(target)
