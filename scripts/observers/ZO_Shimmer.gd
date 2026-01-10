extends Observer
class_name ZO_ShimmerObserver


func watch() -> Resource:
	return ZC_Shimmer


func _add_shimmer(entity: Entity, component: Resource) -> void:
	var shimmer = component as ZC_Shimmer
	for node_path in shimmer.nodes:
		var node = entity.get_node(node_path)
		if node is GeometryInstance3D:
			node.material_overlay = shimmer.material


func _remove_shimmer(entity: Entity, component: Resource):
	var shimmer = component as ZC_Shimmer
	for node_path in shimmer.nodes:
		var node = entity.get_node(node_path)
		if node is GeometryInstance3D:
			node.material_overlay = null


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	if property == 'enabled':
		if new_value and not old_value:
			_add_shimmer(entity, component)

		if old_value and not new_value:
			_remove_shimmer(entity, component)


func on_component_removed(entity: Entity, component: Resource) -> void:
	assert(false, "Someone removed a shimmer component instead of disabling it.")
	_remove_shimmer(entity, component)
