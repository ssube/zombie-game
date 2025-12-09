extends ZM_BaseMenu

signal new_game_pressed()
signal load_game_pressed()
signal exit_pressed()


func on_update() -> void:
	pass


func _on_new_game_pressed() -> void:
	new_game_pressed.emit()
	

func _on_load_game_pressed() -> void:
	load_game_pressed.emit()
	

func _on_exit_pressed() -> void:
	exit_pressed.emit()
