extends PathFollow3D
## Scriptable path follow node with automatic start, loop, and speed control.
class_name ZN_PathFollow3D


@export var start_on_ready: bool = true
@export var reset_on_start: bool = true
@export var duration: float = 5.0  # Time in seconds to complete one loop
@export var pause_between_loops: float = 0.0
@export var hide_between_loops: bool = true
@export var reverse: bool = false
@export var path: Path3D
## Starting position along the path (0.0 to 1.0). Use to stagger multiple instances.
@export_range(0.0, 1.0) var path_offset: float = 0.0


var _is_moving: bool = false
var _tween: Tween


func _ready() -> void:
	if start_on_ready:
		start()


func start() -> void:
	_is_moving = true

	if _tween:
		_tween.kill()
	_tween = create_tween()

	if reset_on_start:
		self.progress_ratio = path_offset

	if reverse:
		# From offset to 0.0
		var phase1_duration := duration * path_offset
		if phase1_duration > 0.0:
			_tween.tween_property(self, "progress_ratio", 0.0, phase1_duration)

		# Wrap to 1.0
		_tween.tween_callback(func(): self.progress_ratio = 1.0)

		# From 1.0 back to offset
		var phase2_duration := duration * (1.0 - path_offset)
		if phase2_duration > 0.0:
			_tween.tween_property(self, "progress_ratio", path_offset, phase2_duration)
	else:
		# From offset to 1.0
		var phase1_duration := duration * (1.0 - path_offset)
		if phase1_duration > 0.0:
			_tween.tween_property(self, "progress_ratio", 1.0, phase1_duration)

		# Wrap to 0.0
		_tween.tween_callback(func(): self.progress_ratio = 0.0)

		# From 0.0 back to offset
		var phase2_duration := duration * path_offset
		if phase2_duration > 0.0:
			_tween.tween_property(self, "progress_ratio", path_offset, phase2_duration)

	_tween.tween_callback(_on_tween_completed)


func stop() -> void:
	_is_moving = false
	if _tween:
		_tween.kill()
		_tween = null


func _on_tween_completed() -> void:
	if pause_between_loops > 0.0:
		if hide_between_loops:
			visible = false
		await get_tree().create_timer(pause_between_loops).timeout
		if hide_between_loops:
			visible = true

	if loop and _is_moving:
		start()
