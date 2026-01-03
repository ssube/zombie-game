extends ZM_BaseMenu

@export var title_image_rect: TextureRect

@export var title_image: Texture2D

signal new_game_pressed()
signal load_game_pressed()
signal exit_pressed()


func on_update() -> void:
	if title_image:
		title_image_rect.texture = title_image
		title_image_rect.visible = true
	else:
		title_image_rect.visible = false


func _on_new_game_pressed() -> void:
	new_game_pressed.emit()


func _on_load_game_pressed() -> void:
	load_game_pressed.emit()


func _on_exit_pressed() -> void:
	exit_pressed.emit()


func _on_controls_button_pressed() -> void:
	menu_changed.emit(Menus.OPTIONS_MENU, 0)


func _on_options_button_pressed() -> void:
	menu_changed.emit(Menus.OPTIONS_MENU, 2)
