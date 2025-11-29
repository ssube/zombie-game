@tool
extends ZE_Base
class_name ZE_Zombie

@export var behavior: NodePath
@export var look_speed: float = 5.0
@export var move_speed: float = 5.0

@onready var root_3d := get_node(".") as RigidBody3D

var look_direction: Vector3 = Vector3.ZERO
var movement_direction: Vector3 = Vector3.ZERO

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
	var current_vel := root_3d.linear_velocity

	# Build target velocity
	var target_vel := movement_direction * move_speed
	target_vel.y = current_vel.y  # Preserve gravity

	# Blend toward target
	root_3d.apply_central_force(current_vel.lerp(target_vel, 0.2))
	look_follow(delta, root_3d.global_transform, look_direction)


func set_look_direction(dir: Vector3) -> void:
	look_direction = dir # .normalized()
	look_direction.y = self.global_position.y

# Call this from your ZombieBehavior script
func set_movement_direction(dir: Vector3) -> void:
	movement_direction = dir.normalized()
	movement_direction.y = 0

func look_follow(_delta: float, current_transform: Transform3D, target_position: Vector3) -> void:
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
	var torque_strength := angular_diff * root_3d.mass * 10.0  # Adjust multiplier as needed

	root_3d.apply_torque(Vector3(0, torque_strength, 0))