extends ZM_BaseMenu

@export var visible_menu: Menus = Menus.NONE
var previous_menu: Menus = Menus.START_MENU

var pause_menus: Dictionary[Menus, bool] = {
	Menus.NONE: false,
	Menus.DIALOGUE_BALLOON: false,
}

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
	Menus.START_MENU: $MenuLayer/StartMenu,
	Menus.EXIT_DIALOG: $MenuLayer/ExitDialog,
	Menus.DIALOGUE_BALLOON: $MenuLayer/DialogueMenu,
	Menus.CONSOLE_MENU: $MenuLayer/ConsoleMenu,
	Menus.LEVEL_END_MENU: $MenuLayer/LevelEndMenu,
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
	$MenuLayer/GameHud.push_action(action)

func clear_ammo_label() -> void:
	$MenuLayer/GameHud.clear_ammo_label()

func clear_target_label() -> void:
	$MenuLayer/GameHud.clear_target_label()

func clear_weapon_label() -> void:
	$MenuLayer/GameHud.clear_weapon_label()

func reset_crosshair_color() -> void:
	$MenuLayer/GameHud.reset_crosshair_color()

func set_ammo_label(text: String) -> void:
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


func show_menu(menu: Menus) -> void:
	if menu != visible_menu:
		var menu_name := Menus.keys()[menu] as String
		print("Show menu: ", menu_name)

		var menu_pause := pause_menus.get(menu, true) as bool
		set_pause(menu_pause)

		previous_menu = visible_menu
		visible_menu = menu

		for m in menu_nodes.keys():
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
			vignette_material.set_shader_parameter("softness", strength)
		Effects.WATER:
			effect_node = $EffectLayer/WaterEffect

	if strength == effect_node.modulate.a:
		return

	effect_node.modulate.a = lerp(effect_node.modulate.a, strength, fade_in)

	if effect_node.modulate.a > 0:
		effect_node.visible = true
	else:
		effect_node.visible = false


func _hide_effect_node(node: Node) -> void:
	node.visible = false


func _on_new_game_pressed() -> void:
	print("New game")
	show_menu(Menus.NONE)


func _on_load_game_pressed() -> void:
	show_menu(Menus.LOAD_MENU)


func _on_exit_pressed() -> void:
	if visible_menu == Menus.GAME_OVER_MENU:
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


func _on_check_box_toggled(toggled_on: bool) -> void:
	$PostLayer.visible = toggled_on


func _on_objectives_pressed() -> void:
	show_menu(Menus.OBJECTIVES_MENU)


func _on_inventory_pressed() -> void:
	show_menu(Menus.INVENTORY_MENU)


func _on_options_applied() -> void:
	pass # Replace with function body.


func _on_objective_changed(objective: ZN_BaseObjective) -> void:
	$MenuLayer/GameHud.set_objective_label(objective.title)


func _on_menu_changed(menu: ZM_BaseMenu.Menus) -> void:
	show_menu(menu)


func _on_game_saved(_name: String) -> void:
	var last_save = Time.get_ticks_msec()
	$MenuLayer/ExitDialog.set_last_save(last_save)


func _on_game_loaded(_name: String) -> void:
	pass # Replace with function body.


func _on_shader_toggled(value: bool) -> void:
	$PostLayer.visible = value


func _on_next_level_pressed() -> void:
	var game := TreeUtils.get_game(self)
	game.load_next_level("")
