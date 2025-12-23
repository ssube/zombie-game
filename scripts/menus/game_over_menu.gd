extends ZM_BaseMenu

@export var killed_label: Label
@export var score_label: Label

@export var killed_by: String
@export var score: int

@onready var killed_template: String = killed_label.text
@onready var score_template: String = score_label.text


signal new_game_pressed()
signal exit_pressed()


func _on_new_game_pressed() -> void:
	new_game_pressed.emit()


func _on_exit_pressed() -> void:
	exit_pressed.emit()


func on_update() -> void:
	if killed_by != "":
		killed_label.visible = true
		killed_label.text = killed_template % killed_by
	else:
		killed_label.visible = false

	if score >= 0:
		score_label.visible = true
		score_label.text = score_template % score
	else:
		score_label.visible = false
