extends Observer
class_name ZO_ObjectiveObserver


@onready var main_node: Node = get_tree().root.get_node("/root/Game")


func watch() -> Resource:
	return ZC_Objective


func on_component_changed(_entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant):
	var objective := component as ZC_Objective
	if property == 'is_complete':
		if new_value:
			print("objective completed")
			if objective.load_level:
				main_node.load_level(objective.next_level)
