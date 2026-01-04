extends ZN_BaseAction
## An action that loops over all of the bodies within an area
class_name ZN_ColliderLoop

@export var area: ZN_TriggerArea3D

func _get_area(source: Node) -> ZN_TriggerArea3D:
	if area:
		return area

	if source is ZN_TriggerArea3D:
		return source

	return null


func _run(source: Node, event: Enums.ActionEvent, _actor: Node) -> void:
	var target := _get_area(source)
	if target == null:
		ZombieLogger.error("Loop area must be a trigger area!")
		return

	for collider in target._colliders:
		super._run(source, event, collider)
