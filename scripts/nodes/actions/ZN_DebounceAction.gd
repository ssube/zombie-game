extends ZN_BranchAction
## Debounces execution of child actions.
## Children will only execute after the debounce wait time has elapsed without any new calls.
class_name ZN_DebounceAction

## Time in seconds to wait before executing children. Resets on each call to run_node.
@export var wait_time: float = 0.5

var _debouncer: TimeUtils.Debounce
var _last_source: Node
var _last_event: Enums.ActionEvent
var _last_actor: Node


func _ready() -> void:
	super._ready()

	# Create debouncer with callback to run children
	_debouncer = TimeUtils.debounce(self, wait_time, _on_debounce_timeout)


func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	# Store the parameters for when the debouncer fires
	_last_source = source
	_last_event = event
	_last_actor = actor

	# Start/restart the debouncer
	_debouncer.start()


func _on_debounce_timeout() -> void:
	# Execute all child actions with the stored parameters
	for action in _actions:
		action._run(_last_source, _last_event, _last_actor)
