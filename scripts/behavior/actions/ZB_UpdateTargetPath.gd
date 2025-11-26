@tool
extends ActionLeaf
class_name ZB_UpdateTargetPath


@export var optional: bool = true
@export var success_proximity: float = 1.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor3d = actor as Node3D

	if not blackboard.has_value("target_position"):
		return FAILURE

	var target_position: Vector3 = blackboard.get_value("target_position")
	var proximity: float = actor3d.global_position.distance_to(target_position)
	if proximity < success_proximity:
		return SUCCESS

	var nav_path := get_navigation_path(actor3d, actor3d.global_position, target_position)
	if len(nav_path) == 0:
		if optional:
			return SUCCESS

		return FAILURE

	blackboard.set_value("nav_path", nav_path)
	return SUCCESS


func get_navigation_path(actor3d: Node3D, p_start_position: Vector3, p_target_position: Vector3) -> PackedVector3Array:
	if not actor3d.is_inside_tree():
		return PackedVector3Array()

	var default_map_rid: RID = actor3d.get_world_3d().get_navigation_map()
	var path: PackedVector3Array = NavigationServer3D.map_get_path(
		default_map_rid,
		p_start_position,
		p_target_position,
		true
	)
	return path
