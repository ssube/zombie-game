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
	match disabled:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			if 'disabled' in target:
				target.disabled = false
		Enums.Tristate.TRUE:
			if 'disabled' in target:
				target.disabled = true

	match visible:
		Enums.Tristate.UNSET:
			pass
		Enums.Tristate.FALSE:
			if 'visible' in target:
				target.visible = false
		Enums.Tristate.TRUE:
			if 'visible' in target:
				target.visible = true


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
