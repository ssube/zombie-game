extends ZM_BaseMenu

var visible_menu: Menus = Menus.NONE
var previous_menu: Menus = Menus.START_MENU

var pause_menus: Dictionary[Menus, bool] = {
	Menus.NONE: false,
}
var visible_effects: Dictionary[Effects, float] = {}

func _ready() -> void:
	update_mouse_mode()
	ObjectiveManager.set_menu(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

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

		$MenuLayer/GameHud.visible = (menu == Menus.NONE)
		$MenuLayer/GameOverMenu.visible = (menu == Menus.GAME_OVER_MENU)
		$MenuLayer/InventoryMenu.visible = (menu == Menus.INVENTORY_MENU)
		$MenuLayer/LoadMenu.visible = (menu == Menus.LOAD_MENU)
		$MenuLayer/LoadingMenu.visible = (menu == Menus.LOADING_MENU)
		$MenuLayer/ObjectivesMenu.visible = (menu == Menus.OBJECTIVES_MENU)
		$MenuLayer/OptionsMenu.visible = (menu == Menus.OPTIONS_MENU)
		$MenuLayer/PauseMenu.visible = (menu == Menus.PAUSE_MENU)
		$MenuLayer/SaveMenu.visible = (menu == Menus.SAVE_MENU)
		$MenuLayer/StartMenu.visible = (menu == Menus.START_MENU)
		$MenuLayer/ExitDialog.visible = (menu == Menus.EXIT_DIALOG)

		update_mouse_mode()

		match menu:
			Menus.GAME_OVER_MENU:
				$MenuLayer/GameOverMenu.on_show()
			Menus.INVENTORY_MENU:
				$MenuLayer/InventoryMenu.on_show()
			Menus.LOAD_MENU:
				$MenuLayer/LoadMenu.on_show()
			Menus.LOADING_MENU:
				$MenuLayer/LoadingMenu.on_show()
			Menus.OBJECTIVES_MENU:
				$MenuLayer/ObjectivesMenu.on_show()
			Menus.OPTIONS_MENU:
				$MenuLayer/OptionsMenu.on_show()
			Menus.PAUSE_MENU:
				$MenuLayer/PauseMenu.on_show()
			Menus.SAVE_MENU:
				$MenuLayer/SaveMenu.on_show()
			Menus.START_MENU:
				$MenuLayer/StartMenu.on_show()
			Menus.EXIT_DIALOG:
				$MenuLayer/ExitDialog.on_show()


## If the effect is visible, fade out
func hide_effect(effect: Effects) -> void:
	if effect not in visible_effects:
		return

	visible_effects.erase(effect)
	match effect:
		Effects.ACID:
			$EffectLayer/AcidEffect.visible = false
		Effects.DAMAGE:
			$EffectLayer/DamageEffect.visible = false
		Effects.FIRE:
			$EffectLayer/FireEffect.visible = false
		Effects.VIGNETTE:
			$EffectLayer/VignetteEffect.visible = false
		Effects.WATER:
			$EffectLayer/WaterEffect.visible = false


func show_effect(effect: Effects, duration: float, strength: float = 1.0, fade_in: float = 0.2) -> void:
	strength = clampf(strength, 0.0, 1.0)

	var effect_node: Control
	match effect:
		Effects.ACID:
			effect_node = $EffectLayer/AcidEffect
		Effects.DAMAGE:
			effect_node = $EffectLayer/DamageEffect
		Effects.FIRE:
			effect_node = $EffectLayer/FireEffect
		Effects.VIGNETTE:
			effect_node = $EffectLayer/VignetteEffect
			var vignette_material := $EffectLayer/VignetteEffect.material as ShaderMaterial
			vignette_material.set_shader_parameter("softness", strength)
		Effects.WATER:
			effect_node = $EffectLayer/WaterEffect

	if effect not in visible_effects:
		effect_node.modulate.a = 0.0
		effect_node.visible = true
		
	visible_effects[effect] = duration

	var tween := create_tween()
	tween.tween_property(effect_node, "modulate:a", strength, fade_in)

	if duration < INF:
		tween.tween_property(effect_node, "modulate:a", 0, duration)
		tween.tween_callback(hide_effect.bind(effect))


func _on_new_game_pressed() -> void:
	print("New game")
	show_menu(Menus.NONE)


func _on_load_game_pressed() -> void:
	show_menu(Menus.LOAD_MENU)


func _on_exit_pressed() -> void:
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
