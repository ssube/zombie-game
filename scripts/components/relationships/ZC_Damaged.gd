extends Component
class_name ZC_Damaged

@export var damaged_at: float
@export var damaged_by: String
@export var cause_of_death: String

func _init(by: String, cause: String = "") -> void:
	damaged_at = Time.get_unix_time_from_system()
	damaged_by = by
	cause_of_death = cause
