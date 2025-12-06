class_name ObjectiveManager

enum ObjectiveType { COUNT, FLAG }
enum ObjectiveFlags { REQUIRED, OPTIONAL }

@export var counts: Dictionary[String, bool] = {}
@export var flags: Dictionary[String, bool] = {}

signal flag_changed(name: String, old_value: bool, new_value: bool)
signal count_changed(name: String, old_value: int, new_value: int)

func reset_all() -> void:
	counts.clear()
	flags.clear()

func set_flag(name: String, value: bool = true) -> void:
	var old_value = flags.get(name, 0)
	flags[name] = value
	flag_changed.emit(name, old_value, value)

func set_count(name: String, value: int) -> void:
	var old_value = counts.get(name, 0)
	counts[name] = value
	count_changed.emit(name, old_value, value)

func add_count(name: String, value: int = 1) -> int:
	var old_value = counts.get(name, 0)
	var new_value = old_value + value
	counts[name] = new_value
	count_changed.emit(name, old_value, new_value)
	return new_value
