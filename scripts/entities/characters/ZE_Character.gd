@tool
extends ZE_Base
class_name ZE_Character

@export_group("Looking")
@export var look_speed: float = 5.0
@export var look_acceleration: float = 10.0

@export_group("Movement")
@export var move_speed: float = 5.0
@export var move_acceleration: float = 2.0

@onready var physics_3d := get_node(".") as RigidBody3D
@onready var root_3d := get_node(".") as Node3D

var look_direction: Vector3 = Vector3.ZERO:
	set(value):
		look_direction = value
		look_direction.y = root_3d.global_position.y

var movement_direction: Vector3 = Vector3.ZERO:
	set(value):
		movement_direction = value
		movement_direction.y = 0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if physics_3d == null:
		return

	apply_movement_force(delta)
	apply_look_torque(delta, physics_3d.global_transform, look_direction)

## Rotate to face target position
func look_at_target(look_target_position: Vector3) -> void:
	look_direction = look_target_position

## Move toward target position
func move_to_target(move_target_position: Vector3) -> void:
	var modifiers = self.get_relationships(RelationshipUtils.any_modifier)

	var speed_multiplier := 1.0
	for modifier: Relationship in modifiers:
		if modifier.target is ZC_Effect_Speed:
			speed_multiplier *= modifier.target.multiplier

	var target_offset: Vector3 = move_target_position - physics_3d.global_position
	target_offset = target_offset.normalized() * move_speed * speed_multiplier
	set_actor_velocity(target_offset)

## Update the physics velocity of the actor node
func set_actor_velocity(target_velocity: Vector3) -> void:
	# print("Setting actor velocity to: ", target_velocity)
	movement_direction = target_velocity

## Gradually update the physics velocity of the actor node
func lerp_actor_velocity(target_velocity: Vector3, delta: float) -> void:
	var current_velocity: Vector3 = movement_direction
	var new_velocity: Vector3 = current_velocity.lerp(target_velocity, minf(delta, 1.0))
	if new_velocity.length_squared() < 1.0:
		new_velocity = Vector3.ZERO

	movement_direction = new_velocity

func apply_movement_force(_delta: float) -> void:
	var current_vel := physics_3d.linear_velocity
	var current_horizontal := Vector3(current_vel.x, 0, current_vel.z)

	# Target horizontal velocity
	var target_horizontal := movement_direction * move_speed

	# Calculate velocity difference (same pattern as angular_diff in apply_look_torque)
	var velocity_diff := target_horizontal - current_horizontal

	# Apply force proportional to difference (same pattern as torque calculation)
	# F = m * a, where we want acceleration proportional to velocity error
	var force := velocity_diff * physics_3d.mass * move_acceleration

	physics_3d.apply_central_force(force)

func apply_look_torque(_delta: float, current_transform: Transform3D, target_position: Vector3) -> void:
	var forward_dir := -current_transform.basis.z  # Forward is -Z in Godot
	var to_target := (target_position - current_transform.origin)
	to_target.y = 0  # Only rotate on Y axis

	if is_zero_approx(to_target.length_squared()):
		return

	to_target = to_target.normalized()
	forward_dir.y = 0
	forward_dir = forward_dir.normalized()

	# Calculate signed angle on Y axis
	var cross := forward_dir.cross(to_target)
	var dot := forward_dir.dot(to_target)
	var angle_diff := atan2(cross.y, dot)

	# Calculate desired angular velocity (proportional control with damping)
	var desired_angular_vel := angle_diff * look_speed
	var current_angular_vel := physics_3d.angular_velocity.y

	# Apply torque to reach desired angular velocity (with built-in damping)
	var angular_diff := desired_angular_vel - current_angular_vel
	var torque_strength := angular_diff * physics_3d.mass * look_acceleration

	physics_3d.apply_torque(Vector3(0, torque_strength, 0))
