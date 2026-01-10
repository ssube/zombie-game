extends ZM_BaseMenu


@export var sign_title: Label
@export var sign_text: RichTextLabel
# TODO: customize buttons


func _on_close_button_pressed() -> void:
	back_pressed.emit()


func on_update() -> void:
	pass


func set_data(data: Dictionary) -> void:
	var source := data.get("source", null) as Entity
	var c_sign := source.get_component(ZC_Sign) as ZC_Sign
	if c_sign == null:
		return

	sign_title.text = c_sign.sign_title
	sign_text.text = c_sign.sign_text
	sign_text.scroll_to_line(0)
