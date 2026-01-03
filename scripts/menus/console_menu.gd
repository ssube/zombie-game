extends ZM_BaseMenu

@export var command_input: LineEdit
@export var command_history: RichTextLabel


signal command_submitted(command: String)


var _history: Array[String] = []


func _run_command(text: String) -> void:
	var words := text.split(" ")
	if words.size() == 0:
		return

	var keyword = words[0]
	match keyword:
		"load":
			var level := words[1]
			var spawn := "Markers/Start"
			if words.size() > 2:
				spawn = words[2]

			print("Loading level %s from the console..." % level)
			var game := TreeUtils.get_game(self)
			game.load_level(level, spawn)
		"menu":
			var menu_index := int(words[1])
			var menu := TreeUtils.get_menu(self)
			menu.show_menu(menu_index)


func _on_console_input_text_submitted(text: String) -> void:
	command_submitted.emit(text)
	_run_command(text)

	_history.append(text)
	command_input.text = ""
	on_update()


func on_show() -> void:
	super.on_show()
	command_input.grab_focus()


func on_update() -> void:
	var history := "\n".join(_history)
	command_history.text = history


func _on_run_button_pressed() -> void:
	var text := command_input.text
	_on_console_input_text_submitted(text)
