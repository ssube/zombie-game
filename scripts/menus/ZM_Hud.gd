extends Node

enum HudMenu {
	START_MENU,
	PAUSE_MENU,
	LOADING_MENU,
	GAME_OVER_MENU,
	LOAD_MENU,
	SAVE_MENU,
	OPTIONS_MENU,
	NONE
}

@export var health_bar: ProgressBar = null
@export var crosshair: TextureRect = null
@onready var crosshair_default_color: Color = crosshair.modulate

var health_tween: Tween = null
var visible_menu: HudMenu = HudMenu.NONE
var previous_menu: HudMenu = HudMenu.START_MENU

func set_crosshair_color(color: Color) -> void:
	crosshair.modulate = color

func reset_crosshair_color() -> void:
	crosshair.modulate = crosshair_default_color # Color.WHITE

func set_health(value: int, instant: bool = false) -> void:
	if health_tween != null:
		health_tween.kill()

	if instant:
		health_bar.value = value
	else:
		health_tween = health_bar.create_tween()
		health_tween.tween_property(health_bar, "value", value, 1.0)
		health_tween.tween_callback(health_callback.bind(value))


func health_callback(value: int) -> void:
	if value <= 0:
		set_pause(true)
		show_menu(HudMenu.GAME_OVER_MENU)


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

		$HudLayer/GameHud.visible = (menu == HudMenu.NONE)
		$HudLayer/StartMenu.visible = (menu == HudMenu.START_MENU)
		$HudLayer/LoadingMenu.visible = (menu == HudMenu.LOADING_MENU)
		$HudLayer/PauseMenu.visible = (menu == HudMenu.PAUSE_MENU)
		$HudLayer/GameOverMenu.visible = (menu == HudMenu.GAME_OVER_MENU)
		$HudLayer/LoadMenu.visible = (menu == HudMenu.LOAD_MENU)
		$HudLayer/SaveMenu.visible = (menu == HudMenu.SAVE_MENU)


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


func _on_level_loading(_old_level: String, _new_level: String) -> void:
	show_menu(HudMenu.LOADING_MENU)


func _on_level_loaded(_old_level: String, _new_level: String) -> void:
	show_menu(HudMenu.NONE)


func _on_check_box_toggled(toggled_on: bool) -> void:
	$GameLayer.visible = toggled_on
