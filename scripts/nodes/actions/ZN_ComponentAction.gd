extends ZN_BaseAction
class_name ZN_ComponentAction

@export var components: Array[Component] = []
@export var mode: Enums.CRUD = Enums.CRUD.CREATE

func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	match mode:
		Enums.CRUD.ADD:
			actor.add_components(components)
		Enums.CRUD.REMOVE:
			actor.remove_components(components)
		Enums.CRUD.UPDATE:
			_update_components(actor, components)


func _update_components(_entity: Entity, _components: Array[Component]) -> void:
	# TODO: only update components that are already present, do not add new ones
	pass
