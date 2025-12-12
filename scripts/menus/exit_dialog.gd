extends ZM_BaseMenu


var _last_save_time: int = 0

@onready var last_save_template: String = %LastSaveLabel.text


signal quit_pressed()


func _format_duration(a_seconds: int, b_seconds: int) -> String:
	var diff := abs(a_seconds - b_seconds) as int

	# Base units
	var seconds := float(diff)
	var minutes := seconds / 60.0
	var hours := seconds / 3600.0
	var days := seconds / 86400.0

	var value := 0.0
	var unit := ""

	# Pick the most appropriate unit
	if days >= 1.0:
		value = days
		unit = "day" if value < 2.0 else "days"
	elif hours >= 1.0:
		value = hours
		unit = "hour" if value < 2.0 else "hours"
	elif minutes >= 1.0:
		value = minutes
		unit = "minute" if value < 2.0 else "minutes"
	else:
		value = seconds
		unit = "second" if value < 2.0 else "seconds"

	# Formatting rule:
	# - If value < 10 → one decimal place
	# - If value >= 10 → integer
	var formatted := ""
	if value < 10.0 and minutes >= 1.0:
		formatted = String("%.1f" % value)
	else:
		formatted = String("%d" % int(value))

	return "%s %s" % [formatted, unit]


func set_last_save(time: int) -> void:
	_last_save_time = time


func on_update() -> void:
	var current_time := Time.get_ticks_msec()
	var elapsed_minutes := "forever"
	if _last_save_time > 0:
		@warning_ignore("integer_division")
		var current_seconds := current_time / 1000
		@warning_ignore("integer_division")
		var last_save_seconds := _last_save_time/ 1000

		elapsed_minutes = _format_duration(current_seconds, last_save_seconds)
		elapsed_minutes = elapsed_minutes.trim_prefix("+")

	%LastSaveLabel.text = last_save_template % elapsed_minutes


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_quit_button_pressed() -> void:
	print("Exit from menu")
	quit_pressed.emit()
	get_tree().quit()
