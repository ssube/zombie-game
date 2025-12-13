extends Component
class_name ZC_Ammo

@export var ammo_count: Dictionary[String, int] = {}
@export var max_ammo_count: Dictionary[String, int] = {}

static var max_int = 9223372036854775807

func transfer(other: ZC_Ammo) -> ZC_Ammo:
	for ammo_type in other.ammo_count.keys():
		var current_count := ammo_count.get(ammo_type, 0) as int
		var max_count := max_ammo_count.get(ammo_type, max_int) as int
		var other_count := other.ammo_count.get(ammo_type) as int

		var max_transfer := max_count - current_count
		max_transfer = mini(other_count, max_transfer)

		current_count = current_count + max_transfer
		other_count = other_count - max_transfer

		ammo_count[ammo_type] = current_count
		other.ammo_count[ammo_type] = other_count

	return self

func min_ammo(other: ZC_Ammo) -> ZC_Ammo:
	for ammo_type in other.ammo_count.keys():
		var current_count := ammo_count.get(ammo_type, 0) as int
		var other_count := other.ammo_count.get(ammo_type) as int

		current_count = mini(current_count, other_count)
		ammo_count[ammo_type] = current_count

	return self

func max_ammo(other: ZC_Ammo) -> ZC_Ammo:
	for ammo_type in other.ammo_count.keys():
		var current_count := ammo_count.get(ammo_type, 0) as int
		var other_count := other.ammo_count.get(ammo_type) as int

		current_count = maxi(current_count, other_count)
		ammo_count[ammo_type] = current_count

	return self

func add_ammo(ammo_type: String, count: int) -> int:
	var current_count := get_ammo(ammo_type)
	current_count += count
	set_ammo(ammo_type, current_count)
	return current_count

func remove_ammo(ammo_type: String, count: int) -> int:
	var current_count := get_ammo(ammo_type)
	current_count -= count
	set_ammo(ammo_type, current_count)
	return current_count

func get_ammo(ammo_type: String) -> int:
	return ammo_count.get(ammo_type, 0)

func get_max_ammo(ammo_type: String) -> int:
	return max_ammo_count.get(ammo_type, max_int)

func set_ammo(ammo_type: String, count: int) -> ZC_Ammo:
	# TODO: check max ammo
	assert(count >= 0, "Ammo count must be a positive integer!")
	ammo_count[ammo_type] = count
	return self
