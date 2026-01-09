extends ZM_BaseMenu


func _on_close_button_pressed() -> void:
	menu_changed.emit(Menus.NONE)


func on_update() -> void:
	pass
