@tool
extends Node3D
class_name ZN_RemoteTransform3D
## A RemoteTransform3D that can be configured via script and has an array of target nodes.

enum TransformSpace {
	LOCAL,
	GLOBAL,
}


@export var active: bool = true:
	set(value):
		active = value
		if value == false:
			reset()

@export var target_nodes: Array[Node3D] = []
@export var transform_space: TransformSpace = TransformSpace.GLOBAL
@export var reset_marker: Marker3D = null


func _is_target_valid(target: Node3D) -> bool:
	return target != null and is_instance_valid(target)


func _process(_delta: float) -> void:
	if not active:
		return

	for target in target_nodes:
		if not _is_target_valid(target):
			continue

		match transform_space:
			TransformSpace.LOCAL:
				target.transform = self.transform
			TransformSpace.GLOBAL:
				target.global_transform = self.global_transform


func reset() -> void:
	if not reset_marker:
		return

	for target in target_nodes:
		if not _is_target_valid(target):
			continue

		match transform_space:
			TransformSpace.LOCAL:
				target.transform = reset_marker.transform
			TransformSpace.GLOBAL:
				target.global_transform = reset_marker.global_transform
