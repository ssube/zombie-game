extends Observer
class_name ZO_ButtonObserver


func watch() -> Resource:
	return ZC_Button


func on_component_changed(
	entity: Entity, component: Resource, property: String, new_value: Variant, _old_value: Variant
) -> void:
	var button := component as ZC_Button
	var is_pressed := new_value as bool
	if property == "is_pressed":
		if button.cooldown_delay > 0:
			entity.add_component(ZC_Cooldown.new(button.cooldown_delay))

		# TODO: actor should be source of a pressed relationship
		if not is_pressed:
			ActionUtils.run_entity(entity, Enums.ActionEvent.BUTTON_RELEASE, entity)
			return

		ActionUtils.run_entity(entity, Enums.ActionEvent.BUTTON_PRESS, entity)

		if button.is_toggle:
			return

		# not a toggle button
		if button.reset_delay > 0:
			var reset_timer := get_tree().create_timer(button.reset_delay)
			reset_timer.timeout.connect(_release_button.bind(button))
		else:
			_release_button(button)


func _release_button(button: ZC_Button) -> void:
	button.is_pressed = false
