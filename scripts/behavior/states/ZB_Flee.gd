extends ZB_State
class_name ZB_State_Flee

## Distance from flee position considered safe
@export var safe_radius: float = 10.0

## How close to the target position before considering we've arrived
@export var point_proximity: float = 1.0

## How often to update navigation path (seconds)
@export var navigation_interval: float = 1.0

var navigation_path: PackedVector3Array = []
var navigation_timer: float = 0.0
var target_position: Vector3 = Vector3.ZERO

func enter(_entity: Entity) -> void:
	navigation_timer = 0.0
	target_position = Vector3.ZERO

func tick(entity: Entity, delta: float, behavior: ZC_Behavior) -> TickResult:
	# Get flee position from blackboard
	var flee_position = behavior.blackboard.get(BehaviorUtils.flee_position)
	if flee_position == null:
		printerr("No flee_position in blackboard for entity: ", entity.id)
		return TickResult.FORCE_EXIT

	var node_3d := entity.root_3d as Node3D
	var current_pos := node_3d.global_position

	# Check if we're already at safe distance
	var distance_from_threat := current_pos.distance_to(flee_position)
	if distance_from_threat >= safe_radius:
		return TickResult.CHECK

	# Calculate flee target position (away from threat, at safe radius)
	if target_position == Vector3.ZERO:
		var flee_direction = (current_pos - flee_position).normalized()
		target_position = flee_position + flee_direction * safe_radius

	# Update movement to look away from threat
	# Follow navigation path
	navigation_path = NavigationUtils.follow_navigation_path(node_3d, navigation_path, point_proximity)

	# Update navigation path periodically
	navigation_timer -= delta
	if navigation_timer <= 0.0:
		navigation_timer = navigation_interval
		navigation_path = NavigationUtils.update_navigation_path(node_3d, target_position)

	# Check if we've reached the target position
	if NavigationUtils.is_point_nearby(node_3d, target_position, point_proximity):
		return TickResult.CHECK

	return TickResult.CONTINUE
