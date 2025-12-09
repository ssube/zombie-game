extends ZM_BaseMenu


@export var save_list: ItemList


signal game_loaded(name: String)


func on_update() -> void:
	# TODO: update the list of saved games
	pass


func _on_saved_games_item_activated(index: int) -> void:
	var save_name := save_list.get_item_text(index)
	game_loaded.emit(save_name)


func _on_back_pressed() -> void:
	back_pressed.emit()
