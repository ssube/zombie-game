extends ZM_BaseMenu

signal new_game_pressed()
signal exit_pressed()


func _on_new_game_pressed() -> void:
	new_game_pressed.emit()


func _on_exit_pressed() -> void:
	exit_pressed.emit()
