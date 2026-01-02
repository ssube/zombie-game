extends ZB_State
class_name ZB_State_Idle_Swim

## How far up and down to bob (in meters)
@export var bob_amplitude: float = 0.5

## How fast to bob (cycles per second)
@export var bob_frequency: float = 0.5

## Horizontal drift radius (0 = no drift)
@export var drift_radius: float = 0.5

## How often to pick a new drift target (seconds)
@export var drift_interval: float = 3.0

## How often to check for state transitions (seconds)
@export var check_interval: float = 5.0

var center_position: Vector3 = Vector3.ZERO
var bob_time: float = 0.0
var drift_timer: float = 0.0
var drift_offset: Vector3 = Vector3.ZERO
var check_timer: float = 0.0


func enter(entity: Entity) -> void:
	var node_3d := entity.root_3d as Node3D
	center_position = node_3d.global_position
	bob_time = 0.0
	drift_timer = 0.0
	drift_offset = Vector3.ZERO
	check_timer = check_interval


func tick(entity: Entity, delta: float, _behavior: ZC_Behavior) -> TickResult:
	bob_time += delta
	drift_timer -= delta
	check_timer -= delta

	var node_3d := entity.root_3d as Node3D

	# Update drift offset periodically
	if drift_timer <= 0.0:
		drift_timer = drift_interval
		if drift_radius > 0.0:
			var random_x := randf_range(-drift_radius, drift_radius)
			var random_z := randf_range(-drift_radius, drift_radius)
			drift_offset = Vector3(random_x, 0.0, random_z)

	# Get navmesh Y at current position (ocean floor)
	var current_horizontal := node_3d.global_position
	var default_map_rid: RID = node_3d.get_world_3d().get_navigation_map()
	var navmesh_point := NavigationServer3D.map_get_closest_point(default_map_rid, current_horizontal)
	var navmesh_y := navmesh_point.y

	# Calculate bobbing Y offset using sine wave
	var bob_offset := sin(bob_time * bob_frequency * TAU) * bob_amplitude
	var desired_y := center_position.y + bob_offset

	# Clamp Y between navmesh (floor) and initial position (surface)
	var clamped_y := clampf(desired_y, navmesh_y, center_position.y)

	# Calculate target position (center + drift + clamped bob)
	var target_position := center_position + drift_offset
	target_position.y = clamped_y

	# Set movement target
	var movement := entity.get_component(ZC_Movement) as ZC_Movement
	if movement != null:
		movement.set_move_target(target_position)
		# Clear look target to prevent rotation during idle
		movement.clear_look_target()

	# Check for transitions periodically
	if check_timer <= 0.0:
		check_timer = check_interval
		return TickResult.CHECK

	return TickResult.CONTINUE
