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

		if not is_pressed:
			return

		if button.is_toggle:
			return
			
		# not a toggle button
		if button.reset_delay > 0:
			var reset_timer := get_tree().create_timer(button.reset_delay)
			reset_timer.timeout.connect(_release_button.bind(entity, button))



func _release_button(entity: Entity, button: ZC_Button) -> void:
	button.is_pressed = false

	var event := ZN_TriggerArea3D.AreaEvent.BUTTON_RELEASED

	var actions_node := entity.get_node(button.released_actions)
	if actions_node:
		ActionUtils.run_node(actions_node, entity, null, event)

	var extra_actions := entity.get_component(ZC_Action) as ZC_Action
	if extra_actions:
		ActionUtils.run_component(extra_actions, entity, null, event)
