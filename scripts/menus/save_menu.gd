extends ZM_BaseMenu

@export var save_list: ItemList


signal game_saved(name: String)


func _on_new_save_pressed() -> void:
	pass # Replace with function body.


func _on_saved_games_item_activated(index: int) -> void:
	var save_name := save_list.get_item_text(index)
	game_saved.emit(save_name)

func _on_back_pressed() -> void:
	back_pressed.emit()


func on_update() -> void:
	pass
