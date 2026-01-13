extends ZN_BaseAction
class_name ZN_NodeAction

@export var node: Node = null
@export var remove: bool = false
@export var disabled: Enums.Tristate = Enums.Tristate.UNSET
@export var visible: Enums.Tristate = Enums.Tristate.UNSET


func _get_target(other: Node) -> Entity:
	if node:
		return node

	return other


func _toggle_node(target: Node) -> void:
	var state: int = TreeUtils.NodeState.NONE
	var mask: int = TreeUtils.NodeState.NONE

	if disabled != Enums.Tristate.UNSET:
		mask |= TreeUtils.NodeState.ENABLED
		if disabled == Enums.Tristate.FALSE:
			state |= TreeUtils.NodeState.ENABLED

	if visible != Enums.Tristate.UNSET:
		mask |= TreeUtils.NodeState.VISIBLE
		if visible == Enums.Tristate.TRUE:
			state |= TreeUtils.NodeState.VISIBLE

	TreeUtils.toggle_node(
		target, 
		state as TreeUtils.NodeState, 
		mask as TreeUtils.NodeState
	)


func _remove_node(target: Node) -> void:
	var parent := target.get_parent()
	if parent:
		parent.remove_child(target)

	target.queue_free()


func run_node(_source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	var target := _get_target(actor)

	_toggle_node(target)

	if remove:
		_remove_node(target)
