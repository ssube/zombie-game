extends ZB_State
## Limits how often another state will run, by time or frames
class_name ZB_ThrottleState

@export var frame_interval: int = -1
@export var time_interval: float = 1.0
@export var skip_state: TickResult = TickResult.CONTINUE

var _tick_delta: int = 0
var _time_delta: float = 0.0
var _child: ZB_State = null


func _ready() -> void:
	var children := self.get_children()
	assert(children.size() == 1, "The state throttle helper should have exactly one child state!")
	_child = children[0]


func tick(entity: Entity, delta: float, behavior: ZC_Behavior) -> int:
	_tick_delta += 1
	_time_delta += delta

	var should_run := false
	var run_delta := delta

	if _tick_delta >= frame_interval:
		_tick_delta = 0
		should_run = true

	if _time_delta >= time_interval:
		run_delta = _time_delta
		_time_delta = 0.0
		should_run = true

	if should_run:
		return _child.tick(entity, run_delta, behavior)

	return skip_state
