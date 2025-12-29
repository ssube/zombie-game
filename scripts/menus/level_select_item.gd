extends Control
class_name ZM_LevelSelectItem

signal level_selected(level_name: String)

@export var title_label: Label
@export var level_image: TextureRect

@export_group("State")
@export var key: String = ""
@export var title: String = "":
	set(value):
		title = value
		title_label.text = value
@export var image: Texture2D = null:
	set(value):
		image = value
		level_image.texture = value


func _on_button_pressed() -> void:
	level_selected.emit(key)
