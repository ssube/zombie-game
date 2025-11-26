extends Observer
class_name ZO_PortalObserver


@onready var main_node: Node = get_tree().root.get_node("/root/Game")


func watch() -> Resource:
	return ZC_Portal


func on_component_changed(_entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant):
	var portal := component as ZC_Portal
	if property == 'is_active':
		if new_value:
			print("Portal is active, loading level: ", portal.next_level)
			main_node.load_level(portal.next_level, portal.spawn_point)
