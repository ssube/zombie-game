extends ZM_BaseMenu


@export var show_name_dialog: bool = false:
	set(value):
		show_name_dialog = value
		$SaveListContainer.visible = not value
		$SaveNameContainer.visible = value


@export var show_replace_dialog: bool = false:
	set(value):
		show_replace_dialog = value
		$SaveListContainer.visible = not value
		$ReplaceConfirmContainer.visible = value


@export var save_list: ItemList
var selected_name: String


signal game_saved(name: String)


func _on_new_save_pressed() -> void:
	show_name_dialog = true


func _on_saved_games_item_activated(index: int) -> void:
	selected_name = save_list.get_item_text(index)
	show_replace_dialog = true


func _on_back_pressed() -> void:
	back_pressed.emit()


func on_show() -> void:
	show_name_dialog = false
	super.on_show()


func on_update() -> void:
	var saves := SaveManager.list_saves()
	save_list.clear()
	for save in saves:
		save_list.add_item(save)


func _on_dialog_save_button_pressed() -> void:
	var save_name = %SaveName.text
	if save_name == "":
		return

	SaveManager.save_game(save_name)
	game_saved.emit(save_name)

	on_update()
	show_name_dialog = false


func _on_dialog_back_button_pressed() -> void:
	show_name_dialog = false
	show_replace_dialog = false


func _on_dialog_replace_button_pressed() -> void:
	SaveManager.save_game(selected_name)
	game_saved.emit(selected_name)
	
	on_update()
	show_replace_dialog = false
