extends ZM_BaseMenu
class_name ZM_LevelSelectMenu


@export var level_item: PackedScene = null
@export var level_list: VBoxContainer


func on_update() -> void:
	var game := TreeUtils.get_game(self)
	var levels := game.campaign.levels

	for child in level_list.get_children():
		level_list.remove_child(child)

	for level in levels:
		var item := level_item.instantiate() as ZM_LevelSelectItem
		level_list.add_child(item)

		item.key = level.key
		item.title = level.title

		if level.loading_image != null:
			item.image = level.loading_image

		item.level_selected.connect(_on_level_selected)


func _on_level_selected(level_key: String) -> void:
	var game := TreeUtils.get_game(self)
	game.load_level(level_key, "Markers/Start")


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_load_button_pressed() -> void:
	apply_pressed.emit()
