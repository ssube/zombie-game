extends ZB_State_Wander
class_name ZB_State_Wander_Swim

## Minimum swim height offset above navmesh (ocean floor)
@export var swim_height_min: float = 1.0

## Node3D to use for initial position reference (sets swim_height_max_absolute)
@export var initial_position: Node3D

var spawn_height: float = 0.0
var swim_height_max_absolute: float = 0.0


func _ready() -> void:
	if initial_position != null:
		swim_height_max_absolute = initial_position.global_position.y


func enter(entity: Entity) -> void:
	super.enter(entity)
	# Store the entity's spawn height as fallback
	spawn_height = entity.root_3d.global_position.y


func update_wander_target(entity) -> void:
	# Get a random horizontal position from the navmesh
	var random_pos := NavigationUtils.pick_random_position(entity, wander_radius)

	# Calculate valid swim range: min height above floor to spawn height (or absolute max)
	var navmesh_y := random_pos.y
	var min_swim_y := navmesh_y + swim_height_min
	var max_swim_y := swim_height_max_absolute

	# Pick a random height within the valid range
	var target_y := randf_range(min_swim_y, max_swim_y)

	target_position = Vector3(random_pos.x, target_y, random_pos.z)

	# Get navigation path to the horizontal position (navmesh), we'll handle vertical separately
	navigation_path = NavigationUtils.update_navigation_path(entity, random_pos)
	wander_timer = wander_interval
