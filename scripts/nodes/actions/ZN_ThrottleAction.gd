extends ZN_BranchAction
## Throttles execution of child actions.
## Children will execute immediately on first call, then ignore subsequent calls until the interval elapses.
class_name ZN_ThrottleAction

## Time in seconds to wait before allowing another execution.
@export var interval: float = 0.5

var _timer: Timer
var _is_throttled: bool = false


func _ready() -> void:
	super._ready()

	# Create timer for throttle interval
	_timer = Timer.new()
	_timer.wait_time = interval
	_timer.one_shot = true
	_timer.timeout.connect(_on_throttle_timeout)
	add_child(_timer)


func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	# If we're in the throttle period, ignore this call
	if _is_throttled:
		return

	# Execute children immediately
	for action in _actions:
		action._run(source, event, actor)

	# Start throttle period
	_is_throttled = true
	_timer.start()


func _on_throttle_timeout() -> void:
	# Throttle period has elapsed, allow next execution
	_is_throttled = false
