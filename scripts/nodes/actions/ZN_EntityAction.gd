extends ZN_BaseAction
class_name ZN_EntityAction

@export var target: Entity = null

@export var remove: bool = false

func run(_actor: Entity, _area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	if remove:
		EntityUtils.remove(target)
