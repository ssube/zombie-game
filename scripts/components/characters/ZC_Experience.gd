extends Component
class_name ZC_Experience

enum LevelMode {
	LINEAR,
	EXPONENTIAL,
}

@export_group("XP")
@export var base_xp: int = 0
@export var earned_xp: int = 0:
	set(value):
		earned_xp = value
		_level_cache = calculate_level()

var total_xp: int:
	get():
		return base_xp + earned_xp
	set(_value):
		assert(false, "Total XP is read-only!")

@export_group("Level")
@export var level_increment: float = 1000
@export var level_mode: LevelMode = LevelMode.LINEAR

var _level_cache: int = 0
var level: int:
	get():
		return _level_cache
	set(_value):
		assert(false, "Level is read-only!")

@export_group("Transfer")
@export var transfer_max: int = -1
@export var transfer_ratio: float = 1.0


func calculate_level() -> int:
	if level_increment <= 0:
		return 0

	match level_mode:
		LevelMode.LINEAR:
				# Series: 1000, 2000, 3000... (level_increment * n)
			return int(total_xp / level_increment)
		LevelMode.EXPONENTIAL:
				# Series: 1000, 4000, 9000... (level_increment * n^2)
			return int(sqrt(float(total_xp) / level_increment))
		_:
			return 0


func clear() -> void:
	base_xp = 0
	earned_xp = 0


func get_transfer_xp() -> int:
	var transfer_xp := base_xp + int(earned_xp * transfer_ratio)
	if transfer_max >= 0:
		transfer_xp = mini(transfer_max, transfer_xp)
	return transfer_xp
