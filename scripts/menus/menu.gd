extends ZM_BaseMenu
class_name ZM_Menu

@export var visible_menu: Menus = Menus.NONE
var previous_menu: Menus = Menus.MAIN_MENU

var _custom_menu: ZM_BaseMenu = null


const pause_menus: Dictionary[Menus, bool] = {
	Menus.NONE: false,
	Menus.DIALOGUE_BALLOON: false,
}

const quit_menus: Array[Menus] = [
	Menus.GAME_OVER_MENU,
	Menus.MAIN_MENU,
	Menus.EXIT_DIALOG,
]

const tabbed_menus: Array[Menus] = [
	Menus.OPTIONS_MENU,
]

@onready var menu_nodes: Dictionary[Menus, Control] = {
	Menus.NONE: $MenuLayer/GameHud,
	Menus.GAME_OVER_MENU: $MenuLayer/GameOverMenu,
	Menus.INVENTORY_MENU: $MenuLayer/InventoryMenu,
	Menus.LOAD_MENU: $MenuLayer/LoadMenu,
	Menus.LOADING_MENU: $MenuLayer/LoadingMenu,
	Menus.OBJECTIVES_MENU: $MenuLayer/ObjectivesMenu,
	Menus.OPTIONS_MENU: $MenuLayer/OptionsMenu,
	Menus.PAUSE_MENU: $MenuLayer/PauseMenu,
	Menus.SAVE_MENU: $MenuLayer/SaveMenu,
	Menus.MAIN_MENU: $MenuLayer/StartMenu,
	Menus.EXIT_DIALOG: $MenuLayer/ExitDialog,
	Menus.DIALOGUE_BALLOON: $MenuLayer/DialogueMenu,
	Menus.CONSOLE_MENU: $MenuLayer/ConsoleMenu,
	Menus.LEVEL_END_MENU: $MenuLayer/LevelEndMenu,
	Menus.LEVEL_SELECT_MENU: $MenuLayer/LevelSelectMenu,
	Menus.CONTACT_MENU: $MenuLayer/ContactMenu,
	Menus.CREDITS_MENU: $MenuLayer/CreditsMenu,
}


func _ready() -> void:
	update_mouse_mode()
	ObjectiveManager.set_menu(self)

	$EffectLayer/AcidEffect.modulate.a = 0.0
	$EffectLayer/ArmorEffect.modulate.a = 0.0
	$EffectLayer/DamageEffect.modulate.a = 0.0
	$EffectLayer/FireEffect.modulate.a = 0.0
	$EffectLayer/HealEffect.modulate.a = 0.0
	$EffectLayer/VignetteEffect.material.set_shader_parameter("softness", 0.0)
	$EffectLayer/WaterEffect.modulate.a = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	if visible_menu == Menus.LOADING_MENU:
		return

	if event.is_action_pressed("menu_console"):
		show_console()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("menu_pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("menu_inventory"):
		_on_inventory_pressed()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("menu_objectives"):
		_on_objectives_pressed()
		get_viewport().set_input_as_handled()


func update_mouse_mode() -> void:
	if visible_menu == Menus.NONE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func set_health(value: int, immediate: bool = false) -> void:
	$MenuLayer/GameHud.set_health(value, immediate)

func set_stamina(value: int, immediate: bool = false) -> void:
	$MenuLayer/GameHud.set_stamina(value, immediate)

func set_objective_label(title: String) -> void:
	$MenuLayer/GameHud.set_objective_label(title)

func push_action(action: String) -> void:
	$MenuLayer/GameHud.append_message(ZC_Message.make_interaction(action))

func append_message(message: ZC_Message) -> void:
	$MenuLayer/GameHud.append_message(message)

func clear_ammo_label() -> void:
	$MenuLayer/GameHud.clear_ammo_label()

func clear_target_label() -> void:
	$MenuLayer/GameHud.clear_target_label()

func clear_weapon_label() -> void:
	$MenuLayer/GameHud.clear_weapon_label()

func reset_crosshair_color() -> void:
	$MenuLayer/GameHud.reset_crosshair_color()

func _get_ammo_text(weapon: ZE_Weapon, player_ammo: ZC_Ammo) -> String:
	if player_ammo == null:
		return ""

	var melee_weapon := weapon.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
	if melee_weapon != null:
		var weapon_durability := weapon.get_component(ZC_Durability) as ZC_Durability
		return "Durability: %d/%d" % [
			weapon_durability.current_durability,
			weapon_durability.max_durability,
		]

	var ranged_weapon := EntityUtils.get_ranged_component(weapon)
	if ranged_weapon != null:
		var weapon_ammo := weapon.get_component(ZC_Ammo) as ZC_Ammo
		var player_count := player_ammo.get_ammo(ranged_weapon.ammo_type)
		var weapon_count := weapon_ammo.get_ammo(ranged_weapon.ammo_type)
		var weapon_max := weapon_ammo.get_max_ammo(ranged_weapon.ammo_type)
		var label := "%s: %d/%d + %d" % [
			ranged_weapon.ammo_type,
			weapon_count,
			weapon_max,
			player_count,
		]
		return label

	return ""


func set_ammo_label(weapon: ZE_Weapon, player_ammo: ZC_Ammo) -> void:
	var text := _get_ammo_text(weapon, player_ammo)
	$MenuLayer/GameHud.set_ammo_label(text)


func set_weapon_label(text: String) -> void:
	$MenuLayer/GameHud.set_weapon_label(text)

func set_target_label(text: String) -> void:
	$MenuLayer/GameHud.set_target_label(text)

func set_crosshair_color(color: Color) -> void:
	$MenuLayer/GameHud.set_crosshair_color(color)

func start_dialogue(dialogue: DialogueResource, start_title: String, extras: Array = []) -> void:
	show_menu(ZM_BaseMenu.Menus.DIALOGUE_BALLOON)
	$MenuLayer/DialogueMenu.start(dialogue, start_title, extras)

func set_hints(hints: Array[String]) -> void:
	$MenuLayer/LoadingMenu.hints = hints

func set_level(level_name: String, loading_image: Texture2D, end_image: Texture2D) -> void:
	$MenuLayer/LoadingMenu.level_name = level_name
	$MenuLayer/LoadingMenu.level_image = loading_image
	$MenuLayer/LevelEndMenu.level_image = end_image

func set_next_level(level_name: String) -> void:
	$MenuLayer/LevelEndMenu.next_level = level_name

func set_score(score: int) -> void:
	$MenuLayer/LevelEndMenu.score = score
	$MenuLayer/GameOverMenu.score = score

func set_killer(killer: String) -> void:
	$MenuLayer/GameOverMenu.killed_by = killer

func show_console() -> void:
	show_menu(Menus.CONSOLE_MENU)


func set_pause(pause: bool) -> void:
	get_tree().paused = pause


func toggle_pause() -> void:
	var pause := !get_tree().paused
	if pause:
		show_menu(Menus.PAUSE_MENU)
	else:
		show_menu(Menus.NONE)


func show_custom_menu(scene: PackedScene, pause: bool = true, data: Dictionary = {}) -> void:
	show_menu(Menus.CUSTOM_MENU)
	_custom_menu = scene.instantiate() as ZM_BaseMenu
	assert(_custom_menu != null, "Custom menu is null in show_custom_menu")
	if 'set_data' in _custom_menu:
		_custom_menu.set_data(data)

	$MenuLayer.add_child(_custom_menu)
	_custom_menu.back_pressed.connect(_on_back_pressed)
	_custom_menu.menu_changed.connect(_on_menu_changed)
	_custom_menu.menu_quit_requested.connect(_on_quit_requested)
	set_pause(pause)
	_custom_menu.on_show()


func show_menu(menu: Menus, tab_index: int = -1) -> void:
	if menu != visible_menu:
		var menu_name := Menus.keys()[menu] as String
		ZombieLogger.info("Show menu: {0}", [menu_name])

		# If this is the start menu, unload the current level before pausing
		if menu == Menus.MAIN_MENU:
			# TODO: prompt to save before unloading
			var game := TreeUtils.get_game(self)
			game.clear_world()

		if _custom_menu != null and menu != Menus.CUSTOM_MENU:
			_custom_menu.on_hide()
			_custom_menu.queue_free()
			_custom_menu = null

		var menu_pause := pause_menus.get(menu, true) as bool
		set_pause(menu_pause)

		previous_menu = visible_menu
		visible_menu = menu

		for m: Menus in menu_nodes.keys():
			var menu_node := menu_nodes[m]
			if m != visible_menu:
				menu_node.hide()
				if menu_node is ZM_BaseMenu:
					menu_node.on_hide()
				menu_node.process_mode = Control.PROCESS_MODE_DISABLED
			else:
				menu_node.process_mode = Control.PROCESS_MODE_INHERIT
				menu_node.show()
				if menu_node is ZM_BaseMenu:
					menu_node.on_show()

				if tab_index > -1:
					if m in tabbed_menus:
						menu_node.active_tab = tab_index

		update_mouse_mode()


func set_effect_strength(effect: Effects, strength: float = 1.0, fade_in: float = 0.1) -> void:
	strength = clampf(strength, 0.0, 1.0)

	# TODO: move these into a dict and loop
	var effect_node: Control
	match effect:
		Effects.ACID:
			effect_node = $EffectLayer/AcidEffect
		Effects.ARMOR:
			effect_node = $EffectLayer/ArmorEffect
		Effects.DAMAGE:
			effect_node = $EffectLayer/DamageEffect
		Effects.FIRE:
			effect_node = $EffectLayer/FireEffect
		Effects.HEAL:
			effect_node = $EffectLayer/HealEffect
		Effects.VIGNETTE:
			effect_node = $EffectLayer/VignetteEffect
			var vignette_material := $EffectLayer/VignetteEffect.material as ShaderMaterial
			var softness := clampf(strength, 0.1, 1.0)
			vignette_material.set_shader_parameter("softness", softness)
		Effects.WATER:
			effect_node = $EffectLayer/WaterEffect

	if strength == effect_node.modulate.a:
		return

	# TODO: should probably be multiplied by delta so fade_in can be seconds
	effect_node.modulate.a = lerp(strength, effect_node.modulate.a, fade_in)

	if effect_node.modulate.a > 0:
		effect_node.visible = true
	else:
		effect_node.visible = false


func _hide_effect_node(node: Node) -> void:
	node.visible = false


func _on_new_game_pressed() -> void:
	show_menu(Menus.LEVEL_SELECT_MENU)


func _on_load_game_pressed() -> void:
	show_menu(Menus.LOAD_MENU)


func _on_exit_pressed() -> void:
	if visible_menu in quit_menus:
		get_tree().quit()
	else:
		show_menu(Menus.EXIT_DIALOG)


func _on_resume_pressed() -> void:
	show_menu(Menus.NONE)


func _on_save_game_pressed() -> void:
	show_menu(Menus.SAVE_MENU)


func _on_options_pressed() -> void:
	show_menu(Menus.OPTIONS_MENU)


func _on_back_pressed() -> void:
	show_menu(previous_menu)


func _on_level_loading(_old_level: String, _new_level: String) -> void:
	show_menu(Menus.LOADING_MENU)


func _on_level_loaded(_old_level: String, _new_level: String) -> void:
	show_menu(Menus.NONE)


func _on_objectives_pressed() -> void:
	show_menu(Menus.OBJECTIVES_MENU)


func _on_inventory_pressed() -> void:
	show_menu(Menus.INVENTORY_MENU)


func _on_options_applied() -> void:
	pass


func _on_objective_changed(objective: ZN_BaseObjective) -> void:
	$MenuLayer/GameHud.set_objective_label(objective.title)


func _on_menu_changed(menu: ZM_BaseMenu.Menus, tab_index: int = -1) -> void:
	show_menu(menu, tab_index)


func _on_game_saved(_name: String) -> void:
	var last_save = Time.get_ticks_msec()
	$MenuLayer/ExitDialog.set_last_save(last_save)


func _on_game_loaded(_name: String) -> void:
	SaveManager.load_game(_name, TreeUtils.get_game(self))


func _on_shader_toggled(value: bool) -> void:
	$PostLayer.visible = value


func _on_next_level_pressed() -> void:
	var game := TreeUtils.get_game(self)
	game.load_next_level("")


func _on_quit_requested() -> void:
	_on_exit_pressed()
