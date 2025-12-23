extends Component
class_name ZC_Experience

@export_group("XP")
@export var base_xp: int = 0
@export var earned_xp: int = 0:
	set(value):
		var old_xp := earned_xp
		earned_xp = value
		property_changed.emit(self, "earned_xp", old_xp, earned_xp)

var total_xp: int:
	get():
		return base_xp + earned_xp
	set(_value):
		assert(false, "Total XP is read-only!")

@export var level: int = 0

@export_group("Transfer")
@export var transfer_max: int = -1
@export var transfer_ratio: float = 1.0


func clear() -> void:
	base_xp = 0
	earned_xp = 0


func get_transfer_xp() -> int:
	var transfer_xp := base_xp + int(earned_xp * transfer_ratio)
	if transfer_max >= 0:
		transfer_xp = mini(transfer_max, transfer_xp)
	return transfer_xp
