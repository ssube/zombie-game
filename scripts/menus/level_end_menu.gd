extends ZM_BaseMenu

@export var level_label: Label
@export var score_label: Label
@export var next_level_label: Label
@export var level_image_rect: TextureRect

@export var last_level: String
@export var next_level: String
@export var score: int
@export var level_image: Texture2D

@onready var level_template: String = level_label.text
@onready var score_template: String = score_label.text
@onready var next_level_template: String = next_level_label.text


signal next_level_pressed()
signal exit_pressed()


func _on_next_level_pressed() -> void:
	next_level_pressed.emit()


func _on_exit_pressed() -> void:
	exit_pressed.emit()


func on_update() -> void:
	level_label.text = level_template % last_level
	score_label.text = score_template % score
	next_level_label.text = next_level_template % next_level

	if level_image:
		level_image_rect.texture = level_image
		level_image_rect.visible = true
	else:
		level_image_rect.visible = false


func _on_main_menu_button_pressed() -> void:
	menu_changed.emit(ZM_BaseMenu.Menus.MAIN_MENU)


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
