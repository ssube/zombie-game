extends ZM_BaseMenu


func _on_url_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_back_button_pressed() -> void:
	menu_changed.emit(Menus.MAIN_MENU)


func on_update() -> void:
	pass
