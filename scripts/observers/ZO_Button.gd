extends Observer
class_name ZO_ButtonObserver


func watch() -> Resource:
	return ZC_Button


func on_component_changed(
	entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant
) -> void:
	var button := component as ZC_Button
	if property == "is_pressed" and new_value:
		if button.toggle:
			return

		# not a toggle button
		if button.reset_delay > 0:
			var reset_timer := get_tree().create_timer(button.reset_delay)
			reset_timer.timeout.connect(_release_button.bind(entity, button))


func _release_button(entity: Entity, button: ZC_Button) -> void:
	button.is_pressed = false

	var actions := entity.get_node(button.released_actions)
	var event := ZN_TriggerArea3D.AreaEvent.BUTTON_RELEASED

	if actions:
		# TODO: handle parent node being an action as well
		for child in actions.get_children():
			if child is ZN_BaseAction:
				child._run(entity, null, event)
