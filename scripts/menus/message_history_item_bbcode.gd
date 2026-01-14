extends Control


@export_group("Controls")
@export var message_label: RichTextLabel
@export var message_icon: TextureRect

@export_group("State")
@export var message: ZC_Message


func _update_display() -> void:
	if message == null:
		return

	message_label.bbcode_enabled = true
	message_label.text = message.message

	if message.icon == null:
		message_icon.visible = false
	else:
		message_icon.texture = message.icon
		message_icon.visible = true


func _ready() -> void:
	_update_display()


func set_message(new_message: ZC_Message) -> void:
	message = new_message
	_update_display()
