extends Observer
class_name ZO_ShimmerObserver

func watch() -> Resource:
	return ZC_Shimmer


func on_component_added(entity: Entity, component: Resource) -> void:
	var shimmer = component as ZC_Shimmer
	for node_path in shimmer.nodes:
		var node = entity.get_node(node_path)
		if node is GeometryInstance3D:
			node.material_overlay = shimmer.material


func on_component_removed(entity: Entity, component: Resource):
	var shimmer = component as ZC_Shimmer
	for node_path in shimmer.nodes:
		var node = entity.get_node(node_path)
		if node is GeometryInstance3D:
			node.material_overlay = null


func on_component_changed(_entity: Entity, _component: Resource, property: String, new_value: Variant, old_value: Variant):
	if property == 'enabled':
		if new_value and not old_value:
			assert(false, "TODO: add shimmer")

		if old_value and not new_value:
			assert(false, "TODO: remove shimmer")