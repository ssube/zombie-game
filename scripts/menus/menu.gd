extends ZM_BaseMenu

var visible_menu: Menus = Menus.NONE
var previous_menu: Menus = Menus.START_MENU

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
		set_pause(true)
		_on_inventory_pressed()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("menu_objectives"):
		set_pause(true)
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
	if pause:
		show_menu(Menus.PAUSE_MENU)
	else:
		show_menu(Menus.NONE)


func toggle_pause() -> void:
	var pause := !get_tree().paused
	set_pause(pause)


func show_menu(menu: Menus) -> void:
	if menu != visible_menu:
		var menu_name := Menus.keys()[menu] as String
		print("Show menu: ", menu_name)

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


func _on_new_game_pressed() -> void:
	print("New game")
	show_menu(Menus.NONE)
	set_pause(false)


func _on_load_game_pressed() -> void:
	show_menu(Menus.LOAD_MENU)


func _on_exit_pressed() -> void:
	# TODO: prompt to save
	print("Exit from menu")
	get_tree().quit()


func _on_resume_pressed() -> void:
	show_menu(Menus.NONE)
	set_pause(false)


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


func _on_new_save_pressed() -> void:
	SaveManager.save_game("test")


func _on_objectives_pressed() -> void:
	show_menu(Menus.OBJECTIVES_MENU)


func _on_inventory_pressed() -> void:
	show_menu(Menus.INVENTORY_MENU)


func _on_options_applied() -> void:
	pass # Replace with function body.


func _on_objective_changed(objective: ZN_BaseObjective) -> void:
	$GameHud.set_objective_label(objective.title)


func _on_menu_changed(menu: ZM_BaseMenu.Menus) -> void:
	show_menu(menu)


func _on_game_saved(_name: String) -> void:
	pass # Replace with function body.


func _on_game_loaded(_name: String) -> void:
	pass # Replace with function body.


func _on_shader_toggled(value: bool) -> void:
	$PostLayer.visible = value
