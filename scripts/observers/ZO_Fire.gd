extends Observer
class_name ZO_FireObserver

func watch() -> Resource:
	return ZC_Effect_Burning


func on_component_added(entity: Entity, _component: Resource) -> void:
	var flammable = entity.get_component(ZC_Flammable) as ZC_Flammable
	var effect_node = entity.get_node(flammable.effect_path) as Node3D
	if effect_node != null:
		effect_node.visible = true


func on_component_removed(entity: Entity, _component: Resource):
	var flammable = entity.get_component(ZC_Flammable) as ZC_Flammable
	var effect_node = entity.get_node(flammable.effect_path) as Node3D
	if effect_node != null:
		effect_node.visible = false
