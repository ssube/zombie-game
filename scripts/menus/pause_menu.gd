extends ZM_BaseMenu

signal resume_pressed()
signal inventory_pressed()
signal objectives_pressed()
signal save_pressed()
signal load_pressed()
signal options_pressed()
signal exit_pressed()


func _on_resume_pressed() -> void:
	resume_pressed.emit()


func _on_inventory_pressed() -> void:
	inventory_pressed.emit()


func _on_objectives_pressed() -> void:
	objectives_pressed.emit()


func _on_save_game_pressed() -> void:
	save_pressed.emit()


func _on_load_game_pressed() -> void:
	load_pressed.emit()


func _on_options_pressed() -> void:
	options_pressed.emit()


func _on_exit_pressed() -> void:
	exit_pressed.emit()


func on_update() -> void:
	pass
