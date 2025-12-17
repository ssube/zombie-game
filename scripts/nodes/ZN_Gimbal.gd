@tool
extends Node3D
## Node that resists changes to its rotation
class_name ZN_Gimbal

## How long until the node returns to its original rotation, in frames or seconds (if `use_delta` is enabled)
@export var multiplier: float = 0.0
@export var use_delta: bool = false
@export_tool_button("Reset Rotation") var reset_rotation = _reset_rotation

@onready var target_rotation: Vector3 = self.global_rotation


func _reset_rotation() -> void:
	self.rotation = Vector3.ZERO
	target_rotation = self.global_rotation


func _process(delta: float) -> void:
	var factor := multiplier
	if use_delta:
		factor *= delta

	self.global_rotation = lerp(target_rotation, self.global_rotation, factor)
