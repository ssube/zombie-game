extends Component
class_name ZC_Killed

@export var killed_at: float

@export var killed_by: String

func _init(by: String) -> void:
	killed_at = Time.get_unix_time_from_system()
	killed_by = by
