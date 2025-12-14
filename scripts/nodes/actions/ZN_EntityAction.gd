extends ZN_BaseAction
class_name ZN_EntityAction

@export var entity: Entity = null

@export var remove: bool = false

func _get_target(actor: Entity) -> Entity:
	if entity:
		return entity

	return actor

func run_entity(actor: Entity, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	var target := _get_target(actor)
	if remove:
		EntityUtils.remove(target)
