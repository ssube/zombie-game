extends ZM_BaseMenu

@export var objective_tree: Tree

signal objective_changed(objective: ZN_BaseObjective)

func _format_bool(value: bool) -> String:
	if value:
		return "Yes"
	else:
		return "No"


func _format_completed(objective: ZN_BaseObjective) -> String:
	if not objective.active:
		return "Not Active"

	return _format_bool(objective.is_completed())


func _add_objective_children(objective: ZN_BaseObjective, item: TreeItem) -> void:
	var child_item = item.create_child()
	child_item.set_text(0, objective.title)
	child_item.set_text(1, _format_bool(objective.optional))
	child_item.set_text(2, _format_completed(objective))

	for child in objective.get_children():
		if child is ZN_BaseObjective:
			_add_objective_children(child, child_item)


func _on_objective_tree_item_activated() -> void:
	var tree := $MarginContainer/VFlowContainer/ObjectiveTree as Tree
	var item := tree.get_selected() as TreeItem
	var objective_title := item.get_text(0)

	# update the current objective in the HUD
	# check if objective is active and not completed - ready to select
	var objective := ObjectiveManager.find_objective_title(objective_title)
	if objective == null:
		ZombieLogger.warning("Objective not found: {0}", [objective_title])
		return

	if not objective.active:
		ZombieLogger.warning("Objective is not active: {0}", [objective_title])
		return

	if objective.is_completed():
		ZombieLogger.warning("Objective is already completed: {0}", [objective_title])
		return

	objective_changed.emit(objective)
	# objective_label.text = objective_title


func on_update() -> void:
	# objective_tree.text = ObjectiveManager.print_objective_tree()
	objective_tree.clear()
	objective_tree.set_column_title(0, "Objective")
	objective_tree.set_column_title(1, "Optional")
	objective_tree.set_column_title(2, "Completed")
	objective_tree.set_column_title_alignment(0, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	objective_tree.set_column_title_alignment(1, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	objective_tree.set_column_title_alignment(2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	objective_tree.set_column_custom_minimum_width(0, floor(objective_tree.get_rect().size.x * 0.5))
	objective_tree.set_column_custom_minimum_width(1, floor(objective_tree.get_rect().size.x * 0.2))
	objective_tree.set_column_custom_minimum_width(1, floor(objective_tree.get_rect().size.x * 0.2))

	var root_objectives := ObjectiveManager.get_root_objectives()
	for objective in root_objectives:
		var item = objective_tree.create_item()
		item.set_text(0, objective.title)
		item.set_text(1, _format_bool(objective.optional))
		item.set_text(2, _format_completed(objective))

		for child in objective.get_children():
			if child is ZN_BaseObjective:
				_add_objective_children(child, item)


func _on_back_pressed() -> void:
	back_pressed.emit()
