extends Component
class_name ZC_Damaged

@export var damaged_at: float
@export var damaged_by: String

func _init(by: String) -> void:
	damaged_at = Time.get_unix_time_from_system()
	damaged_by = by
