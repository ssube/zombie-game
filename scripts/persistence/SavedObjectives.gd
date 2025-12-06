extends Resource
class_name ZP_SavedObjectives

@export var counts: Dictionary[String, int] = {}
@export var flags: Dictionary[String, bool] = {}

static func from_manager(manager: ObjectiveManager) -> ZP_SavedObjectives:
	var saved := ZP_SavedObjectives.new()

	for objective in manager.objectives.values():
		if objective is ZN_CountObjective:
			saved.counts[objective.key] = objective.current_count

		if objective is ZN_FlagObjective:
			saved.flags[objective.key] = objective.current_value

	return saved
