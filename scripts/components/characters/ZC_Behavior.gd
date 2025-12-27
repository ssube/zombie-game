extends Component
class_name ZC_Behavior

@export var state_machine: NodePath

@export_group("State")
@export var active: bool = true
@export var blackboard: Dictionary[String, Variant] = {}
@export var current_state: String


func _get_blackboard_signal_name(key: StringName) -> String:
		var signal_name := "blackboard:%s" % key
		return signal_name


func set_value(key: StringName, value: Variant) -> void:
	var signal_name := _get_blackboard_signal_name(key)

	if not blackboard.has(key):
		blackboard[key] = value
		property_changed.emit(self, signal_name, null, value)
		return

	var old = blackboard[key]

	# If unchanged, do nothing
	if old == value:
		return

	blackboard[key] = value
	property_changed.emit(self, signal_name, old, value)


func get_value(key: StringName, default: Variant = null) -> Variant:
	return blackboard.get(key, default)


# ----------------------------------------------------
# REMOVE / CLEAR
# ----------------------------------------------------

func remove_value(key: StringName) -> void:
	if not blackboard.has(key):
		return

	var old = blackboard[key]
	blackboard.erase(key)

	var signal_name := _get_blackboard_signal_name(key)
	property_changed.emit(self, signal_name, old, null)


func clear() -> void:
		for key in blackboard.keys():
			var signal_name := _get_blackboard_signal_name(key)
			property_changed.emit(self, signal_name, blackboard[key], null)

		blackboard.clear()


# ----------------------------------------------------
# BOOLEAN HELPERS
# ----------------------------------------------------

func has(key: StringName) -> bool:
		return blackboard.has(key)


func keys() -> Array:
		return blackboard.keys()


func dump() -> Dictionary:
		# returns a copy for debugging
		return blackboard.duplicate(true)
