extends ZN_BaseAction
class_name ZN_ComponentAction

enum ActionMode {
	ADD,
	REMOVE,
	UPDATE,
}

@export var components: Array[Component] = []
@export var mode: ActionMode = ActionMode.ADD

func run(actor: Entity) -> void:
	match mode:
		ActionMode.ADD:
			actor.add_components(components)
		ActionMode.REMOVE:
			actor.remove_components(components)
		ActionMode.UPDATE:
			_update_components(actor, components)


func _update_components(entity: Entity, components: Array[Component]) -> void:
	# TODO: only update components that are already present, do not add new ones
	pass
