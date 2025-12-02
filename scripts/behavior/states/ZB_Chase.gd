extends ZB_State
class_name ZB_State_Chase

@export var chase_timeout: float = 15.0
@export var navigation_interval: float = 1.0
@export var navigation_timer: float = 0.0
@export var point_proximity: float = 1.0

var navigation_path: PackedVector3Array = []

func tick(entity: Entity, delta: float, blackboard: ZB_Blackboard) -> TickResult:
	var target_player: Node3D = blackboard.get_value(BehaviorUtils.target_player)
	if target_player == null:
		return TickResult.FORCE_EXIT

	var target_position := target_player.global_position
	blackboard.set_value(BehaviorUtils.target_position, target_position)
	entity.look_at_target(target_position)
	# print("Zombie is chasing player at position: ", target_position)

	var node_3d := entity.root_3d as Node3D
	NavigationUtils.follow_navigation_path(node_3d, navigation_path, point_proximity)

	navigation_timer -= delta
	if navigation_timer > 0.0:
		return TickResult.CONTINUE

	navigation_timer = navigation_interval
	navigation_path = NavigationUtils.update_navigation_path(node_3d, target_position)
	return TickResult.CONTINUE
