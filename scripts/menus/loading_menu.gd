extends ZM_BaseMenu

@export var hints: Array[String] = []
@export var hint_index: int = 0
@export var hint_interval: float = 2.0
@export var hint_label: Label

@export var level_name: String
@export var level_label: Label

@onready var level_template = level_label.text

var hint_timer: float = 0.0

signal hint_shown(hint: String)


func on_update() -> void:
	_show_next_hint()
	_update_level_label()


func _process(delta: float) -> void:
	if not self.visible:
		return

	hint_timer += delta
	if hint_timer > hint_interval:
		_fade_next_hint()


func _fade_next_hint() -> void:
	hint_timer = 0.0

	var tween := self.create_tween()
	tween.tween_property(hint_label, "modulate:a", 0.0, 0.25)
	tween.tween_callback(_show_next_hint)
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.25)


func _show_next_hint() -> void:
	hint_index = (hint_index + 1) % hints.size()
	hint_label.text = hints[hint_index]
	hint_shown.emit(hints[hint_index])
	hint_timer = 0.0


func _update_level_label() -> void:
	var text: String = level_template % level_name
	level_label.text = text
