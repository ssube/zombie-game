@tool
extends ZE_Base
class_name ZE_Zombie

@export var behavior: NodePath
@export var look_speed: float = 5.0
@export var move_speed: float = 5.0
@export var look_acceleration: float = 10.0
@export var move_acceleration: float = 2.0

@onready var root_3d := get_node(".") as RigidBody3D

var look_direction: Vector3 = Vector3.ZERO:
	set(value):
		look_direction = value
		look_direction.y = root_3d.global_position.y

var movement_direction: Vector3 = Vector3.ZERO:
	set(value):
		movement_direction = value
		movement_direction.y = 0

func on_ready():
	# Sync transform from scene to component
	var transform = get_component(ZC_Transform) as ZC_Transform
	if not transform:
		return

	transform.position = root_3d.global_position
	transform.rotation = root_3d.global_rotation

	var behavior_node = get_node(behavior) as Node
	if behavior_node != null:
		behavior_node.on_ready(self)

	print("Zombie class: ", self.get_class())

func _physics_process(delta: float) -> void:
	apply_movement_force(delta)
	apply_look_torque(delta, root_3d.global_transform, look_direction)

func set_look_direction(dir: Vector3) -> void:
	look_direction = dir # .normalized()
	look_direction.y = self.global_position.y

func set_movement_direction(dir: Vector3) -> void:
	movement_direction = dir # .normalized()
	movement_direction.y = 0

func apply_movement_force(_delta: float) -> void:
	var current_vel := root_3d.linear_velocity
	var current_horizontal := Vector3(current_vel.x, 0, current_vel.z)

	# Target horizontal velocity
	var target_horizontal := movement_direction * move_speed

	# Calculate velocity difference (same pattern as angular_diff in apply_look_torque)
	var velocity_diff := target_horizontal - current_horizontal

	# Apply force proportional to difference (same pattern as torque calculation)
	# F = m * a, where we want acceleration proportional to velocity error
	var force := velocity_diff * root_3d.mass * move_acceleration

	root_3d.apply_central_force(force)

func apply_look_torque(_delta: float, current_transform: Transform3D, target_position: Vector3) -> void:
	var forward_dir := -current_transform.basis.z  # Forward is -Z in Godot
	var to_target := (target_position - current_transform.origin)
	to_target.y = 0  # Only rotate on Y axis

	if to_target.length_squared() < 0.001:
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
	var current_angular_vel := root_3d.angular_velocity.y

	# Apply torque to reach desired angular velocity (with built-in damping)
	var angular_diff := desired_angular_vel - current_angular_vel
	var torque_strength := angular_diff * root_3d.mass * look_acceleration

	root_3d.apply_torque(Vector3(0, torque_strength, 0))