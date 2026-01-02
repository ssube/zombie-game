extends Observer
class_name ZO_LightObserver


func watch() -> Resource:
	return ZC_Light


func on_component_changed(
	entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant
) -> void:
	if property == "enabled":
		var light := component as ZC_Light
		if light != null:
			for node_path in light.node_paths:
				var light_node := entity.get_node(node_path)
				if light_node is Light3D:
					light_node.visible = new_value
				elif light_node is ZN_LightGroup:
					light_node.enabled = new_value
