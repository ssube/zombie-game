extends ZN_BaseAction
class_name ZN_SkinAction

@export var target_entity: Entity

@export var set_skin: bool = true
@export var new_skin: ZC_Skin.SkinType

func _get_target(actor: Entity) -> Entity:
	if target_entity:
		return target_entity

	return actor


func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var target := _get_target(actor)
	var skin := target.get_component(ZC_Skin) as ZC_Skin
	if skin == null:
		return

	if set_skin:
		skin.current_skin = new_skin
