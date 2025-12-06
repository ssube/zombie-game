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

@export_group("Labels")
@export var objective_label: Label = null
@export var target_label: Label = null
@export var weapon_label: Label = null

@export_group("Actions")
@export var action_label: Label = null
@export var action_limit: int = 5
@export var action_timeout: float = 5.0

@onready var crosshair_default_color: Color = crosshair.modulate

var action_queue: Array[String] = []
var action_timer: float = 0.0
var health_tween: Tween = null
var visible_menu: HudMenu = HudMenu.NONE
var previous_menu: HudMenu = HudMenu.START_MENU

func _ready() -> void:
	clear_objective_label()
	clear_target_label()
	clear_weapon_label()
	reset_crosshair_color()
	update_mouse_mode()

func _process(delta: float) -> void:
	if action_queue.size() > 0:
		action_timer += delta
		if action_timer >= action_timeout:
			action_timer = 0.0
			action_queue.pop_front()
			update_action_queue.call_deferred()

func set_crosshair_color(color: Color) -> void:
	crosshair.modulate = color

func reset_crosshair_color() -> void:
	crosshair.modulate = crosshair_default_color # Color.WHITE

func push_action(action: String) -> void:
	action_queue.append(action)
	if action_queue.size() > action_limit:
		action_queue.pop_front()

	action_timer = 0.0
	update_action_queue()

func clear_objective_label() -> void:
	objective_label.text = ""
	set_objective_visible(false)

func set_objective_label(text: String) -> void:
	objective_label.text = text
	set_objective_visible(text != "")

func set_objective_visible(visible: bool = true) -> void:
	objective_label.visible = visible

func clear_target_label() -> void:
	target_label.text = ""

func set_target_label(text: String) -> void:
	target_label.text = text

func clear_weapon_label() -> void:
	weapon_label.text = ""

func set_weapon_label(text: String) -> void:
	weapon_label.text = text

func set_health(value: int, instant: bool = false) -> void:
	if health_tween != null:
		health_tween.kill()

	if instant:
		health_bar.value = value
		health_callback(value)
	else:
		health_tween = health_bar.create_tween()
		health_tween.tween_property(health_bar, "value", value, 0.5)
		health_tween.tween_callback(health_callback.bind(value))


func health_callback(value: int) -> void:
	if value <= 0:
		set_pause(true)
		show_menu(HudMenu.GAME_OVER_MENU)


func update_mouse_mode() -> void:
	if visible_menu == HudMenu.NONE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func update_action_queue() -> void:
	if action_queue.size() > 0:
		action_label.text = "\n".join(action_queue)
	else:
		action_label.text = ""


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

		update_mouse_mode()


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
	$PostLayer.visible = toggled_on


func _on_new_save_pressed() -> void:
	var query = ECS.world.query.with_all([C_Persistent])
	var data = ECS.serialize(query)

	var user_dir := DirAccess.open("user://")
	if not user_dir.dir_exists("saves"):
		user_dir.make_dir("saves")

	if ECS.save(data, "user://saves/test.tres"):
		print("Saved %d entities!" % data.entities.size())
