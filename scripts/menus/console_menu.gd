extends ZM_BaseMenu

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
			var game := get_tree().root.get_node("/root/Game")
			game.load_level(level, spawn)


func _on_console_input_text_submitted(text: String) -> void:
	command_submitted.emit(text)
	_run_command(text)

	_history.append(text)
	on_update()


func on_show() -> void:
	super.on_show()
	$MarginContainer/VBoxContainer/ConsoleInput.grab_focus()


func on_update() -> void:
	var history := "\n".join(_history)
	$MarginContainer/VBoxContainer/ConsoleHistory.text = history
