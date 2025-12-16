extends ZN_BaseAction
class_name ZN_EntityAction

@export var entity: Entity = null
@export var remove: bool = false


func _get_target(actor: Entity) -> Entity:
	if entity:
		return entity

	return actor


func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var target := _get_target(actor)
	if remove:
		EntityUtils.remove(target)


## Support for objectives and other node types
func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	if entity:
		EntityUtils.remove(entity)
