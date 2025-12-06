extends Observer
class_name ZO_ObjectiveObserver

func watch() -> Resource:
	return ZC_Objective

func on_component_changed(
	_entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant
) -> void:
	var objective := component as ZC_Objective
	if property == "is_active":
		if new_value:
			ObjectiveManager.activate_objective(objective.key)
		else:
			ObjectiveManager.deactivate_objective(objective.key)

	if property == "is_complete":
		ObjectiveManager.set_flag(objective.key, new_value)
