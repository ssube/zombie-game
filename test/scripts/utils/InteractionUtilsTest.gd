# GdUnit generated TestSuite
class_name InteractionUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/utils/InteractionUtils.gd'
const __script = preload(__source)


func test_valid_interactions() -> void:
	for interaction in __script.interactions:
		assert_str(interaction).is_not_empty()

		var pair = __script.interactions[interaction]
		assert_array(pair).is_not_null().has_size(2)

		var condition = pair[0]
		var handler = pair[1]
		assert_that(condition).is_not_null()
		assert_that(handler).is_not_null()


#region Condition Functions (has_X)
func test_has_ammo() -> void:
	var entity := ZE_Weapon.new()
	entity.add_component(ZC_Ammo.new())
	var has_ammo = __script.has_ammo(entity)
	entity.queue_free()
	assert_bool(has_ammo).is_true()


func test_has_ammo_false() -> void:
	var entity := ZE_Weapon.new()
	var has_ammo = __script.has_ammo(entity)
	entity.queue_free()
	assert_bool(has_ammo).is_false()


func test_has_armor() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Effect_Armor.new())
	var has_armor = __script.has_armor(entity)
	entity.queue_free()
	assert_bool(has_armor).is_true()


func test_has_armor_false() -> void:
	var entity := Entity.new()
	var has_armor = __script.has_armor(entity)
	entity.queue_free()
	assert_bool(has_armor).is_false()


func test_has_button() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Button.new())
	var has_button = __script.has_button(entity)
	entity.queue_free()
	assert_bool(has_button).is_true()


func test_has_button_false() -> void:
	var entity := Entity.new()
	var has_button = __script.has_button(entity)
	entity.queue_free()
	assert_bool(has_button).is_false()


func test_has_dialogue() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Dialogue.new())
	var has_dialogue = __script.has_dialogue(entity)
	entity.queue_free()
	assert_bool(has_dialogue).is_true()


func test_has_dialogue_false() -> void:
	var entity := Entity.new()
	var has_dialogue = __script.has_dialogue(entity)
	entity.queue_free()
	assert_bool(has_dialogue).is_false()


func test_has_door() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Door.new())
	var has_door = __script.has_door(entity)
	entity.queue_free()
	assert_bool(has_door).is_true()


func test_has_door_false() -> void:
	var entity := Entity.new()
	var has_door = __script.has_door(entity)
	entity.queue_free()
	assert_bool(has_door).is_false()


func test_has_food() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Food.new())
	var has_food = __script.has_food(entity)
	entity.queue_free()
	assert_bool(has_food).is_true()


func test_has_food_false() -> void:
	var entity := Entity.new()
	var has_food = __script.has_food(entity)
	entity.queue_free()
	assert_bool(has_food).is_false()


func test_has_key() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Key.new())
	var has_key = __script.has_key(entity)
	entity.queue_free()
	assert_bool(has_key).is_true()


func test_has_key_false() -> void:
	var entity := Entity.new()
	var has_key = __script.has_key(entity)
	entity.queue_free()
	assert_bool(has_key).is_false()


func test_has_objective() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Objective.new())
	var has_objective = __script.has_objective(entity)
	entity.queue_free()
	assert_bool(has_objective).is_true()


func test_has_objective_false() -> void:
	var entity := Entity.new()
	var has_objective = __script.has_objective(entity)
	entity.queue_free()
	assert_bool(has_objective).is_false()


func test_has_portal() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Portal.new())
	var has_portal = __script.has_portal(entity)
	entity.queue_free()
	assert_bool(has_portal).is_true()


func test_has_portal_false() -> void:
	var entity := Entity.new()
	var has_portal = __script.has_portal(entity)
	entity.queue_free()
	assert_bool(has_portal).is_false()


func test_has_interactive() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Interactive.new())
	var has_interactive = __script.has_interactive(entity)
	entity.queue_free()
	assert_bool(has_interactive).is_true()


func test_has_interactive_false() -> void:
	var entity := Entity.new()
	var has_interactive = __script.has_interactive(entity)
	entity.queue_free()
	assert_bool(has_interactive).is_false()


func test_has_equipment() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Equipment.new())
	var has_equipment = __script.has_equipment(entity)
	entity.queue_free()
	assert_bool(has_equipment).is_true()


func test_has_equipment_false() -> void:
	var entity := Entity.new()
	var has_equipment = __script.has_equipment(entity)
	entity.queue_free()
	assert_bool(has_equipment).is_false()
#endregion


#region Helper Functions
func test_format_button_pressed_on() -> void:
	var result = __script._format_button_pressed(true)
	assert_str(result).is_equal("on")


func test_format_button_pressed_off() -> void:
	var result = __script._format_button_pressed(false)
	assert_str(result).is_equal("off")
#endregion


#region Handler Functions
func test_use_button_toggle_on() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var button := ZC_Button.new()
	button.is_toggle = true
	button.is_active = true
	button.is_pressed = false
	target.add_component(button)

	var menu = mock(ZM_Menu) as ZM_Menu
	var status = __script.use_button(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(button.is_pressed).is_true()

	actor.queue_free()
	target.queue_free()


func test_use_button_toggle_off() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var button := ZC_Button.new()
	button.is_toggle = true
	button.is_active = true
	button.is_pressed = true
	target.add_component(button)

	var menu = mock(ZM_Menu) as ZM_Menu
	var status = __script.use_button(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(button.is_pressed).is_false()

	actor.queue_free()
	target.queue_free()


func test_use_button_not_toggle() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var button := ZC_Button.new()
	button.is_toggle = false
	button.is_active = true
	button.is_pressed = false
	target.add_component(button)

	var menu = mock(ZM_Menu) as ZM_Menu
	var status = __script.use_button(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(button.is_pressed).is_true()

	actor.queue_free()
	target.queue_free()


func test_use_button_inactive() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var button := ZC_Button.new()
	button.is_active = false
	target.add_component(button)

	var menu = auto_free(ZM_Menu.new())
	var status = __script.use_button(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.SKIP)

	actor.queue_free()
	target.queue_free()


func test_use_door_open() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var door := ZC_Door.new()
	door.open_on_use = true
	door.is_open = false
	target.add_component(door)
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var status = __script.use_door(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(door.is_open).is_true()

	actor.queue_free()
	target.queue_free()


func test_use_door_close() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var door := ZC_Door.new()
	door.open_on_use = true
	door.is_open = true
	target.add_component(door)
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var status = __script.use_door(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(door.is_open).is_false()

	actor.queue_free()
	target.queue_free()


func test_use_door_locked() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var door := ZC_Door.new()
	door.open_on_use = true
	door.is_open = false
	target.add_component(door)

	var locked := ZC_Locked.new()
	locked.is_locked = true
	locked.key_name = "test_key"
	target.add_component(locked)
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var status = __script.use_door(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(door.is_open).is_false()

	actor.queue_free()
	target.queue_free()


func test_use_portal_open() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var portal := ZC_Portal.new()
	portal.is_open = true
	portal.is_active = false
	target.add_component(portal)
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var status = __script.use_portal(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(portal.is_active).is_true()

	actor.queue_free()
	target.queue_free()


func test_use_portal_closed() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var portal := ZC_Portal.new()
	portal.is_open = false
	portal.is_active = false
	target.add_component(portal)
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var status = __script.use_portal(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.SKIP)
	assert_bool(portal.is_active).is_false()

	actor.queue_free()
	target.queue_free()


func test_complete_objective_active() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var objective := ZC_Objective.new()
	objective.is_active = true
	objective.complete_on_interaction = true
	objective.is_complete = false
	target.add_component(objective)
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var status = __script.complete_objective(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.CONTINUE)
	assert_bool(objective.is_complete).is_true()

	actor.queue_free()
	target.queue_free()


func test_complete_objective_inactive() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var objective := ZC_Objective.new()
	objective.is_active = false
	objective.complete_on_interaction = true
	objective.is_complete = false
	target.add_component(objective)

	var menu = auto_free(ZM_Menu.new())
	var status = __script.complete_objective(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.SKIP)
	assert_bool(objective.is_complete).is_false()

	actor.queue_free()
	target.queue_free()


func test_complete_objective_no_interaction() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	var objective := ZC_Objective.new()
	objective.is_active = true
	objective.complete_on_interaction = false
	objective.is_complete = false
	target.add_component(objective)

	var menu = auto_free(ZM_Menu.new())
	var status = __script.complete_objective(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.SKIP)
	assert_bool(objective.is_complete).is_false()

	actor.queue_free()
	target.queue_free()


func test_pickup_item_not_pickupable() -> void:
	var actor := ZE_Player.new()
	var target := Entity.new()
	var interactive := ZC_Interactive.new()
	interactive.pickup = false
	target.add_component(interactive)

	var menu = auto_free(ZM_Menu.new())
	var status = __script.pickup_item(actor, target, menu)

	assert_int(status).is_equal(__script.HandlerStatus.SKIP)

	actor.queue_free()
	target.queue_free()
#endregion


#region Edge Cases
func test_interact_with_cooldown() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	target.add_component(ZC_Cooldown.new(5.0))
	target.add_component(ZC_Interactive.new())

	var menu = auto_free(ZM_Menu.new())
	var result = __script.interact(actor, target, menu)

	assert_bool(result).is_false()

	actor.queue_free()
	target.queue_free()


func test_multiple_condition_checks() -> void:
	# Ensure that entities can have multiple components
	var entity := Entity.new()
	entity.add_component(ZC_Ammo.new())
	entity.add_component(ZC_Interactive.new())

	assert_bool(__script.has_ammo(entity)).is_true()
	assert_bool(__script.has_interactive(entity)).is_true()
	assert_bool(__script.has_armor(entity)).is_false()

	entity.queue_free()
#endregion
