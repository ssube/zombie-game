extends ZN_BaseObjective
class_name ZN_CountObjective

@export var starting_count: int = 0
@export var target_count: int = 10
@export var increment: int = 1
@export var allow_more: bool = true
@export var allow_less: bool = false

@onready var current_count: int = starting_count

func is_completed() -> bool:
	if allow_more and current_count >= target_count:
		return true

	if allow_less and current_count <= target_count:
		return true

	return current_count == target_count
