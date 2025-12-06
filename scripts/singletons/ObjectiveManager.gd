extends Node
# class_name ObjectiveManager

# enum ObjectiveStatus {
# 	NEW,
# 	PENDING,
# 	PROGRESS,
# 	COMPLETED,
# 	FAILED,
# }

#@export var counts: Dictionary[String, bool] = {}
#@export var flags: Dictionary[String, bool] = {}

var menu_node: Node = null
var objectives: Dictionary[String, ZN_BaseObjective] = {}
var active_objectives: Dictionary[String, ZN_BaseObjective] = {}

signal flag_changed(objective: ZN_FlagObjective, old_value: bool, new_value: bool)
signal count_changed(objective: ZN_CountObjective, old_value: int, new_value: int)
signal objective_activated(objective: ZN_BaseObjective)
signal objective_changed(objective: ZN_BaseObjective)


func activate_children(objective: ZN_BaseObjective) -> void:
	var children := objective.get_children()
	for child in children:
		if child is ZN_BaseObjective:
			objectives[child.key] = child
			_activate_objective(child)


func _activate_objective(objective: ZN_BaseObjective) -> void:
	if menu_node:
		menu_node.set_objective_label(objective.title)

	objective.active = true
	active_objectives[objective.key] = objective
	objective_activated.emit(objective)


func activate_objective(key: String) -> bool:
	var objective := find_objective(key)
	if objective == null:
		return false

	_activate_objective(objective)
	return true


func deactivate_objective(key: String) -> bool:
	var objective := find_objective(key)
	if objective == null:
		return false

	objective.active = false
	active_objectives.erase(objective.key)
	return true


func find_objective(key: String) -> ZN_BaseObjective:
	return objectives.get(key)


func get_active_objectives() -> Array[ZN_BaseObjective]:
	return active_objectives.values()


func get_objectives() -> Array[ZN_BaseObjective]:
	return objectives.values()


func set_objectives(new_objectives: Array[ZN_BaseObjective] = []) -> void:
	objectives.clear()
	active_objectives.clear()

	for objective in new_objectives:
		add_objective(objective)


func add_objective(objective: ZN_BaseObjective) -> void:
	objectives[objective.key] = objective

	if objective.active:
		_activate_objective(objective)

	for child in objective.get_children():
		if child is ZN_BaseObjective:
			add_objective(child)


func reset_all() -> void:
	for objective in objectives.values():
		if objective is ZN_CountObjective:
			_set_count(objective, objective.starting_count)
		elif objective is ZN_FlagObjective:
			_set_flag(objective, objective.starting_value)


func _set_flag(objective: ZN_FlagObjective, value: bool) -> void:
	var old_value = objective.current_value
	objective.current_value = value

	if old_value != value:
		flag_changed.emit(objective, old_value, value)
		objective_changed.emit(objective)


func set_flag(key: String, value: bool = true) -> bool:
	var objective := find_objective(key)
	if objective == null:
		return false

	if objective is ZN_FlagObjective:
		_set_flag(objective, value)
		if objective.is_completed():
			active_objectives.erase(objective.key)
			activate_children(objective)

	return false


func _set_count(objective: ZN_CountObjective, value: int) -> void:
	var old_value = objective.current_value
	objective.current_value = value

	if old_value != value:
		count_changed.emit(objective, old_value, value)
		objective_changed.emit(objective)


func set_count(key: String, value: int) -> bool:
	var objective := find_objective(key)
	if objective == null:
		return false

	if objective is ZN_CountObjective:
		_set_count(objective, value)
		if objective.is_completed():
			activate_children(objective)

	return false


func increment_count(key: String, value: int = 1) -> int:
	var objective := find_objective(key)
	if objective == null:
		return 0

	if objective is ZN_CountObjective:
		var old_value = objective.current_count
		var new_value = old_value + value
		_set_count(objective, new_value)
		return new_value

	return 0


func set_menu(node: Node) -> void:
	menu_node = node
