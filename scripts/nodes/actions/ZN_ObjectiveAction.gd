extends ZN_BaseAction
class_name ZN_ObjectiveAction

## Action for manipulating objectives. Can target objectives by key through the
## ObjectiveManager, or modify the ZC_Objective component on the actor entity.

enum ObjectiveOperation {
	## Activate the objective
	ACTIVATE,
	## Deactivate the objective
	DEACTIVATE,
	## Mark the objective as complete
	COMPLETE,
	## Increment a count objective's value
	INCREMENT,
	## Decrement a count objective's value
	DECREMENT,
	## Set a flag objective to true
	SET_FLAG_TRUE,
	## Set a flag objective to false
	SET_FLAG_FALSE,
}

enum TargetMode {
	## Target objective by key through ObjectiveManager
	BY_KEY,
	## Target the ZC_Objective component on the actor entity
	ACTOR_COMPONENT,
}

## How to find the target objective
@export var target_mode: TargetMode = TargetMode.BY_KEY

## The objective key (used when target_mode is BY_KEY)
@export var objective_key: String = ""

## The operation to perform on the objective
@export var operation: ObjectiveOperation = ObjectiveOperation.COMPLETE

## The amount to increment/decrement (for INCREMENT/DECREMENT operations)
@export var amount: int = 1

func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	match target_mode:
		TargetMode.BY_KEY:
			_run_by_key()
		TargetMode.ACTOR_COMPONENT:
			_run_on_actor(actor)

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	# For non-entity actors, only BY_KEY mode works
	if target_mode == TargetMode.BY_KEY:
		_run_by_key()

func _run_by_key() -> void:
	if objective_key.is_empty():
		ZombieLogger.warning("ZN_ObjectiveAction: No objective key specified")
		return

	match operation:
		ObjectiveOperation.ACTIVATE:
			ObjectiveManager.activate_objective(objective_key)
		ObjectiveOperation.DEACTIVATE:
			ObjectiveManager.deactivate_objective(objective_key)
		ObjectiveOperation.COMPLETE:
			ObjectiveManager.set_flag_or_increment(objective_key, true, 1)
		ObjectiveOperation.INCREMENT:
			ObjectiveManager.increment_count(objective_key, amount)
		ObjectiveOperation.DECREMENT:
			ObjectiveManager.increment_count(objective_key, -amount)
		ObjectiveOperation.SET_FLAG_TRUE:
			ObjectiveManager.set_flag(objective_key, true)
		ObjectiveOperation.SET_FLAG_FALSE:
			ObjectiveManager.set_flag(objective_key, false)

func _run_on_actor(actor: Entity) -> void:
	if actor == null:
		return

	var objective := actor.get_component(ZC_Objective) as ZC_Objective
	if objective == null:
		ZombieLogger.warning("ZN_ObjectiveAction: Actor has no ZC_Objective component")
		return

	match operation:
		ObjectiveOperation.ACTIVATE:
			objective.is_active = true
		ObjectiveOperation.DEACTIVATE:
			objective.is_active = false
		ObjectiveOperation.COMPLETE:
			objective.is_complete = true
		ObjectiveOperation.INCREMENT, ObjectiveOperation.DECREMENT, \
		ObjectiveOperation.SET_FLAG_TRUE, ObjectiveOperation.SET_FLAG_FALSE:
			# These operations require ObjectiveManager, use the component's key
			if objective.key.is_empty():
				ZombieLogger.warning("ZN_ObjectiveAction: Actor's ZC_Objective has no key for manager operation")
				return
			objective_key = objective.key
			_run_by_key()
