extends ZM_BaseMenu

@export var crosshair: TextureRect = null

@export_group("Bars")
@export var health_bar: ProgressBar = null
@export var stamina_bar: ProgressBar = null

@export_group("Labels")
@export var objective_label: Label = null
@export var target_label: Label = null
@export var weapon_label: Label = null
@export var ammo_label: Label = null

@export_group("Messages")
@export var message_history: Control = null
#@export var action_label: Label = null
#@export var action_limit: int = 5
#@export var action_timeout: float = 5.0

@onready var crosshair_default_color: Color = crosshair.modulate

var action_queue: Array[String] = []
var action_timer: float = 0.0
var health_tween: Tween = null
var stamina_tween: Tween = null

func _ready() -> void:
	clear_objective_label()
	clear_target_label()
	clear_weapon_label()
	clear_ammo_label()
	reset_crosshair_color()

#func _process(delta: float) -> void:
#	if not self.visible:
#		return
#
#	#if action_queue.size() > 0:
#	#	action_timer += delta
#	#	#if action_timer >= action_timeout:
#	#	#	action_timer = 0.0
#	#	#	action_queue.pop_front()
#	#		#update_action_queue.call_deferred()

func set_crosshair_color(color: Color) -> void:
	crosshair.modulate = color

func reset_crosshair_color() -> void:
	crosshair.modulate = crosshair_default_color # Color.WHITE

#func push_action(action: String) -> void:
#	action_queue.append(action)
#	if action_queue.size() > action_limit:
#		action_queue.pop_front()
#
#	action_timer = 0.0
#	update_action_queue()

func append_message(message: ZC_Message) -> void:
	message_history.append_message(message)

func clear_objective_label() -> void:
	objective_label.text = ""
	set_objective_visible(false)

func set_objective_label(text: String) -> void:
	objective_label.text = text
	set_objective_visible(text != "")

func set_objective_visible(value: bool = true) -> void:
	objective_label.visible = value

func clear_target_label() -> void:
	target_label.text = ""

func set_target_label(text: String) -> void:
	target_label.text = text

func clear_weapon_label() -> void:
	weapon_label.text = ""

func set_weapon_label(text: String) -> void:
	weapon_label.text = text

func clear_ammo_label() -> void:
	ammo_label.text = ""

func set_ammo_label(text: String) -> void:
	ammo_label.text = text


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


func set_stamina(value: int, instant: bool = false) -> void:
	if stamina_tween != null:
		stamina_tween.kill()

	if instant:
		stamina_bar.value = value
	else:
		stamina_tween = stamina_bar.create_tween()
		stamina_tween.tween_property(stamina_bar, "value", value, 0.5)


func health_callback(value: int) -> void:
	if value <= 0:
		menu_changed.emit(Menus.GAME_OVER_MENU)


#func update_action_queue() -> void:
#	if action_queue.size() > 0:
#		action_label.text = "\n".join(action_queue)
#	else:
#		action_label.text = ""

func on_update() -> void:
	pass
