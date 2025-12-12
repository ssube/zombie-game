extends ZM_BaseMenu


@export var save_list: ItemList


signal game_loaded(name: String)


func on_update() -> void:
	var saves := SaveManager.list_saves()
	save_list.clear()
	for save in saves:
		save_list.add_item(save)


func _on_saved_games_item_activated(index: int) -> void:
	var save_name := save_list.get_item_text(index)
	game_loaded.emit(save_name)


func _on_back_pressed() -> void:
	back_pressed.emit()


func _on_load_pressed() -> void:
	pass # Replace with function body.
