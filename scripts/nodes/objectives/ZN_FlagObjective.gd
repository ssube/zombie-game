extends ZN_BaseObjective
class_name ZN_FlagObjective

@export var starting_value: bool = false
@export var target_value: bool = true

@onready var current_value: bool = starting_value

func is_completed() -> bool:
	return current_value == target_value
