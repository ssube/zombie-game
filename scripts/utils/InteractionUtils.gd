class_name InteractionUtils

enum HandlerStatus {
	CONTINUE,
	STOP,
	SKIP,
}


static func _add_sound(sound: ZN_AudioSubtitle3D, parent: Node) -> void:
	parent.add_child(sound)


static func _format_button_pressed(pressed: bool) -> String:
	if pressed:
		return "on"
	else:
		return "off"


## Dictionary[String, [Callable[Entity] -> void, Callable[Entity, Entity, Menu] -> HandlerStatus]]
static var interactions: Dictionary[String, Array] = {
	# dialogue and objective should be first, before items
	"start_dialogue": [has_dialogue, start_dialogue],
	"complete_objective": [has_objective, complete_objective],
	# item traits
	"use_armor": [has_armor, use_armor],
	"use_button": [has_button, use_button],
	"use_food": [has_food, use_food],
	# key needs to be checked before door
	"use_key": [has_key, use_key],
	"use_door": [has_door, use_door],
	# weapon needs to be checked before ammo
	"use_weapon": [EntityUtils.is_weapon, use_weapon],
	"use_ammo": [has_ammo, use_ammo],
	"pickup_equipment": [has_equipment, pickup_equipment],
	"pickup_item": [has_interactive, pickup_item],
	# using portal should be last, since it will change the level
	"use_portal": [has_portal, use_portal],
}


#region Public Methods
static func interact(actor: Entity, target: Entity, menu) -> bool:
	if target.has_component(ZC_Cooldown):
		return false

	var interactive = target.get_component(ZC_Interactive) as ZC_Interactive
	if EntityUtils.is_locked(target):
		var locked := target.get_component(ZC_Locked) as ZC_Locked
		if actor.has_key(locked.key_name):
			locked.is_locked = false
			menu.push_action("Used %s key to unlock %s" % [locked.key_name, interactive.name])
		else:
			menu.push_action("Need %s key to use %s" % [locked.key_name, interactive.name])
			return false

	# add used-by relationship, replacing any existing ones
	RelationshipUtils.add_unique_relationship(target, Relationship.new(ZC_Used.new(), actor))

	target.emit_action(Enums.ActionEvent.ENTITY_USE, actor)

	var handled := false
	for key in interactions.keys():
		var handler := interactions[key]
		var check_func := handler[0] as Callable
		var handle_func := handler[1] as Callable
		if check_func.call(target):
			ZombieLogger.debug("Running interaction handler {0} for target {1}", [key, target.name])
			var status := handle_func.call(actor, target, menu) as HandlerStatus
			match status:
				HandlerStatus.CONTINUE:
					handled = true
				HandlerStatus.SKIP:
					continue
				HandlerStatus.STOP:
					return true

	return handled


static func pickup(actor: Entity, target: Entity, menu) -> bool:
	var status := pickup_item(actor, target, menu)
	return status != HandlerStatus.SKIP
#endregion


#region Handlers
static func has_ammo(entity: Entity) -> bool:
	return entity.has_component(ZC_Ammo)


static func use_ammo(actor: Entity, target: Entity, menu) -> HandlerStatus:
	var actor_ammo := actor.get_component(ZC_Ammo) as ZC_Ammo
	var target_ammo := target.get_component(ZC_Ammo) as ZC_Ammo
	actor_ammo.transfer(target_ammo)

	var interactive = target.get_component(ZC_Interactive) as ZC_Interactive
	menu.push_action("Picked up ammo: %s" % interactive.name)

	if interactive.pickup_sound:
		var sound := interactive.pickup_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, actor)

	if EntityUtils.is_ammo_empty(target_ammo):
		EntityUtils.remove(target)
		return HandlerStatus.STOP

	return HandlerStatus.CONTINUE


static func has_armor(entity: Entity) -> bool:
	return entity.has_component(ZC_Effect_Armor)


static func use_armor(actor: Entity, target: Entity, menu) -> HandlerStatus:
	var armor = target as ZE_Armor
	if armor == null:
		return HandlerStatus.SKIP

	target.remove_component(ZC_Shimmer)

	var modifier := armor.get_component(ZC_Effect_Armor) as ZC_Effect_Armor
	var player = actor as ZE_Player
	player.add_relationship(RelationshipUtils.make_modifier_damage(modifier.multiplier))

	EntityUtils.equip_item(player, target)

	var interactive = armor.get_component(ZC_Interactive) as ZC_Interactive
	menu.push_action("Picked up armor: %s" % interactive.name)

	if interactive.use_sound:
		var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, actor)

	# TODO: this should already be handled in the equip item helper
	var entity3d := target.get_node(".") as RigidBody3D
	entity3d.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	entity3d.freeze = true
	entity3d.visible = false

	for child in entity3d.get_children():
		if child is CollisionShape3D:
			child.disabled = true

	return HandlerStatus.CONTINUE


static func has_button(entity: Entity) -> bool:
	return entity.has_component(ZC_Button)


# TODO: link button to actor
static func use_button(_actor: Entity, target: Entity, menu: ZM_Menu) -> HandlerStatus:
	var button := target.get_component(ZC_Button) as ZC_Button
	if not button.is_active:
		return HandlerStatus.SKIP

	# TODO: should add a pressed-by relationship that is used by the button observer
	if button.is_toggle:
		button.is_pressed = not button.is_pressed
		var pressed_message := _format_button_pressed(button.is_pressed)
		menu.push_action("Toggled button %s" % pressed_message)
	else:
		button.is_pressed = true
		menu.push_action("Pressed button")

	return HandlerStatus.CONTINUE


static func has_dialogue(entity: Entity) -> bool:
	return entity.has_component(ZC_Dialogue)


static func start_dialogue(actor: Entity, target: Entity, menu: ZM_Menu) -> HandlerStatus:
	# get level markers
	var markers := TreeUtils.get_markers(target)

	# start dialogue
	var helpers := DialogueUtils.DialogueHelper.new(target, markers)
	var dialogue = target.get_component(ZC_Dialogue)
	menu.start_dialogue(dialogue.dialogue_tree, dialogue.start_title, [
		{
			"dialogue" = dialogue,
			"helpers" = helpers,
			"markers" = markers,
			"player" = actor,
			"speaker" = target,
		}
	])

	return HandlerStatus.CONTINUE


static func has_door(entity: Entity) -> bool:
	return entity.has_component(ZC_Door)


# TODO: link door to actor
static func use_door(_actor: Entity, target: Entity, _menu: ZM_Menu) -> HandlerStatus:
	var door := target.get_component(ZC_Door) as ZC_Door

	if door.open_on_use and not EntityUtils.is_locked(target):
		door.is_open = !door.is_open
		ZombieLogger.debug("Door is open: {0}", [door.is_open])

		var interactive := target.get_component(ZC_Interactive) as ZC_Interactive
		if interactive.use_sound:
			var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
			_add_sound(sound, target)

	return HandlerStatus.CONTINUE


static func has_food(entity: Entity) -> bool:
	return entity.has_component(ZC_Food)


static func use_food(actor: Entity, target: Entity, menu: ZM_Menu) -> HandlerStatus:
	var health = actor.get_component(ZC_Health) as ZC_Health
	if health.current_health >= health.max_health:
		return pickup_item(actor, target, menu)

	var food = target.get_component(ZC_Food) as ZC_Food
	health.current_health += food.health

	var interactive = target.get_component(ZC_Interactive) as ZC_Interactive
	menu.push_action("Used food: %s" % interactive.name)

	if interactive.use_sound:
		var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, actor)

	EntityUtils.remove(target)
	return HandlerStatus.STOP


static func has_key(entity: Entity) -> bool:
	return entity.has_component(ZC_Key)


static func use_key(actor: Entity, target: Entity, menu: ZM_Menu) -> HandlerStatus:
	var player := actor.get_component(ZC_Player) as ZC_Player
	var key = target.get_component(ZC_Key)
	player.add_key(key.name)
	menu.push_action("Found key: %s" % key.name)

	var interactive = target.get_component(ZC_Interactive) as ZC_Interactive
	if interactive.pickup_sound:
		var sound := interactive.pickup_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, actor)

	EntityUtils.remove(target)
	return HandlerStatus.STOP


static func has_objective(entity: Entity) -> bool:
	return entity.has_component(ZC_Objective)


# TODO: link objective to actor
static func complete_objective(_actor: Entity, target: Entity, _menu: ZM_Menu) -> HandlerStatus:
	var objective = target.get_component(ZC_Objective) as ZC_Objective
	if not (objective.is_active and objective.complete_on_interaction):
		return HandlerStatus.SKIP

	objective.is_complete = true
	ZombieLogger.info("Completed objective: {0}", [objective.key])

	var interactive := target.get_component(ZC_Interactive) as ZC_Interactive
	if interactive.use_sound:
		var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, target)

	return HandlerStatus.CONTINUE


static func has_portal(entity: Entity) -> bool:
	return entity.has_component(ZC_Portal)


static func use_portal(_actor: Entity, target: Entity, _menu: ZM_Menu) -> HandlerStatus:
	var portal = target.get_component(ZC_Portal) as ZC_Portal
	if not portal.is_open:
		return HandlerStatus.SKIP

	portal.is_active = true
	ZombieLogger.info("Activated portal: {0}", [portal])

	var interactive := target.get_component(ZC_Interactive) as ZC_Interactive
	if interactive.use_sound:
		var sound := interactive.use_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, target)

	return HandlerStatus.CONTINUE


static func use_weapon(actor: Entity, target: Entity, menu) -> HandlerStatus:
	var weapon = target as ZE_Weapon
	if weapon == null:
		return HandlerStatus.SKIP

	weapon.remove_component(ZC_Shimmer)

	# reparent weapon to player
	var weapon_body = weapon.get_node(".") as RigidBody3D
	weapon_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	weapon_body.freeze = true
	weapon_body.linear_velocity = Vector3.ZERO
	weapon_body.angular_velocity = Vector3.ZERO
	weapon_body.transform = Transform3D.IDENTITY

	var player = actor as ZE_Player
	player.add_relationship(RelationshipUtils.make_holding(weapon))
	EntityUtils.switch_weapon(player, weapon, menu)

	var interactive = weapon.get_component(ZC_Interactive) as ZC_Interactive
	menu.push_action("Found new weapon: %s" % interactive.name)

	return HandlerStatus.STOP


static func has_interactive(entity: Entity) -> bool:
	return entity.has_component(ZC_Interactive)


static func pickup_item(actor: Entity, target: Entity, menu) -> HandlerStatus:
	var interactive = target.get_component(ZC_Interactive) as ZC_Interactive
	if not interactive.pickup:
		return HandlerStatus.SKIP

	target.remove_component(ZC_Shimmer)

	target.get_parent().remove_child(target)
	# target.visible = false

	var player := actor as ZE_Player
	player.inventory_node.add_child(target)

	actor.add_relationship(RelationshipUtils.make_holding(target))

	menu.push_action("Picked up item: %s" % interactive.name)

	if interactive.pickup_sound:
		var sound := interactive.pickup_sound.instantiate() as ZN_AudioSubtitle3D
		_add_sound(sound, actor)

	return HandlerStatus.CONTINUE


static func has_equipment(entity: Entity) -> bool:
	return entity.has_component(ZC_Equipment)


static func pickup_equipment(actor: Entity, target: Entity, menu) -> HandlerStatus:
	var status := pickup_item(actor, target, menu)
	assert(actor is ZE_Character, "Actor must be a character to equip equipment!")
	EntityUtils.equip_item(actor as ZE_Character, target)
	if status == HandlerStatus.CONTINUE:
		return HandlerStatus.STOP

	return status
#endregion
