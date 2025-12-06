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
var current_objective: ZN_BaseObjective = null

signal flag_changed(objective: ZN_FlagObjective, old_value: bool, new_value: bool)
signal count_changed(objective: ZN_CountObjective, old_value: int, new_value: int)
signal objective_activated(objective: ZN_BaseObjective)
signal objective_changed(objective: ZN_BaseObjective)
signal objective_completed(objective: ZN_BaseObjective)
signal current_objective_changed(objective: ZN_BaseObjective)


func activate_children(objective: ZN_BaseObjective) -> void:
	var children := objective.get_children()
	for child in children:
		if child is ZN_BaseObjective:
			objectives[child.key] = child
			_activate_objective(child)


func _activate_objective(objective: ZN_BaseObjective) -> void:
	if menu_node:
		var title := objective.title
		if objective.optional:
			title = "* %s" % title
		menu_node.set_objective_label(title)

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


func get_current_objective() -> ZN_BaseObjective:
	return current_objective


func get_completed_objectives() -> Array[ZN_BaseObjective]:
	var completed: Array[ZN_BaseObjective] = []
	for objective in objectives.values():
		if objective.is_completed():
			completed.append(objective)

	return completed


func get_objectives() -> Array[ZN_BaseObjective]:
	return objectives.values()


func set_objectives(new_objectives: Array[ZN_BaseObjective] = []) -> void:
	objectives.clear()
	active_objectives.clear()

	for objective in new_objectives:
		add_objective(objective)


func set_current_objective(key: String) -> bool:
	var objective := find_objective(key)
	if objective == null:
		return false

	current_objective = objective
	current_objective_changed.emit(objective)
	return true


func add_objective(objective: ZN_BaseObjective) -> void:
	if objective.key in objectives:
		printerr("Duplicate objective key: ", objective, objectives[objective.key])
		return

	objectives[objective.key] = objective

	if objective.active:
		_activate_objective(objective)

	for child in objective.get_children():
		if child is ZN_BaseObjective:
			add_objective(child)


func _complete_objective(objective: ZN_BaseObjective) -> void:
	objective.active = false
	active_objectives.erase(objective.key)
	activate_children(objective)
	objective_completed.emit(objective)

	match objective.game_state:
		ZN_BaseObjective.GameState.NONE:
			return
		ZN_BaseObjective.GameState.WIN:
			_end_game(true)
		ZN_BaseObjective.GameState.LOSE:
			_end_game(false)


func _end_game(_state: bool = true) -> void:
	# delay slightly before showing game over menu
	var timer := get_tree().create_timer(1.0)
	await timer.timeout

	menu_node.set_pause(true)
	menu_node.show_menu(menu_node.HudMenu.GAME_OVER_MENU)


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
			_complete_objective(objective)

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
			_complete_objective(objective)

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


func print_objective_subtree(objective: ZN_BaseObjective, indent: String = "") -> String:
	var subtree: Array[String] = []
	var bullet: String = "-"
	if objective.active:
		bullet = "="
	if objective.is_completed():
		bullet = "+"

	var optional := ""
	if objective.optional:
		optional = "*"

	subtree.append("%s%s%s %s" % [indent, bullet, optional, objective.title])

	var child_indent := indent + "  "
	for child in objective.get_children():
		if child is ZN_BaseObjective:
			subtree.append(print_objective_subtree(child, child_indent))

	return "\n".join(subtree)


func print_objective_tree() -> String:
	var root_objectives: Array[ZN_BaseObjective] = []
	for objective in objectives.values():
		if objective.get_parent() is not ZN_BaseObjective:
			root_objectives.append(objective)

	var subtrees: Array[String] = []
	for objective in root_objectives:
		subtrees.append(print_objective_subtree(objective))

	return "\n".join(subtrees)


func save(path: String) -> bool:
	var saved := ZP_SavedObjectives.from_manager(self)
	var error := ResourceSaver.save(saved, path)
	if error != OK:
		printerr("Error saving objectives: ", error)
		return false

	return true


func load(path: String) -> int:
	var loaded := ResourceLoader.load(path, "ZP_SavedObjectives") as ZP_SavedObjectives
	var counter := 0

	for count_key in loaded.counts:
		var objective := find_objective(count_key)
		if objective is ZN_CountObjective:
			objective.current_count = loaded.counts[count_key]
			counter += 1

	for flag_key in loaded.flags:
		var objective := find_objective(flag_key)
		if objective is ZN_FlagObjective:
			objective.current_value = loaded.flags[flag_key]
			counter += 1

	return counter
