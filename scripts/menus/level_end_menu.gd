extends ZM_BaseMenu

@export var level_label: Label
@export var score_label: Label
@export var next_level_button: Button

@export var last_level: String
@export var next_level: String
@export var score: int

@onready var level_template: String = level_label.text
@onready var score_template: String = score_label.text
@onready var next_level_template: String = next_level_button.text


signal next_level_pressed()
signal exit_pressed()


func _on_next_level_pressed() -> void:
	next_level_pressed.emit()


func _on_exit_pressed() -> void:
	exit_pressed.emit()


func on_update() -> void:
	level_label.text = level_template % last_level
	score_label.text = score_template % score
	next_level_button.text = next_level_template % next_level
