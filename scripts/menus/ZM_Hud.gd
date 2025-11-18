extends Node

enum HudMenu {
	START_MENU,
	PAUSE_MENU,
	LOAD_MENU,
	SAVE_MENU,
	OPTIONS_MENU,
	NONE
}

@export var health_bar: ProgressBar = null

var health_tween: Tween = null
var visible_menu: HudMenu = HudMenu.NONE
var previous_menu: HudMenu = HudMenu.START_MENU

func set_health(value: int, instant: bool = false) -> void:
	if health_tween != null:
		health_tween.kill()

	if instant:
		health_bar.value = value
	else:
		health_tween = health_bar.create_tween()
		health_tween.tween_property(health_bar, "value", value, 1.0)


func set_pause(pause: bool) -> void:
	get_tree().paused = pause
	if pause:
		show_menu(HudMenu.PAUSE_MENU)


func toggle_pause() -> void:
	var pause := !get_tree().paused
	set_pause(pause)


func show_menu(menu: HudMenu) -> void:
	if menu != visible_menu:
		var menu_name := HudMenu.keys()[menu] as String
		print("Show menu: ", menu_name)

		previous_menu = visible_menu
		visible_menu = menu

		$GameHud.visible = (menu == HudMenu.NONE)
		$StartMenu.visible = (menu == HudMenu.START_MENU)
		$PauseMenu.visible = (menu == HudMenu.PAUSE_MENU)
		$LoadMenu.visible = (menu == HudMenu.LOAD_MENU)
		$SaveMenu.visible = (menu == HudMenu.SAVE_MENU)


func _on_new_game_pressed() -> void:
	print("New game")
	show_menu(HudMenu.NONE)
	set_pause(false)


func _on_load_game_pressed() -> void:
	show_menu(HudMenu.LOAD_MENU)


func _on_exit_pressed() -> void:
	# TODO: prompt to save
	print("Exit from menu")
	get_tree().quit()


func _on_resume_pressed() -> void:
	show_menu(HudMenu.NONE)
	set_pause(false)


func _on_save_game_pressed() -> void:
	show_menu(HudMenu.SAVE_MENU)


func _on_back_pressed() -> void:
	show_menu(previous_menu)
