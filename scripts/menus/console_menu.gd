extends ZM_BaseMenu

signal command_submitted(command: String)

var _history: Array[String] = []

func _on_console_input_text_submitted(new_text: String) -> void:
	_history.append(new_text)
	var history := "\n".join(_history)
	$MarginContainer/VBoxContainer/ConsoleHistory.text = history
	command_submitted.emit(new_text)
