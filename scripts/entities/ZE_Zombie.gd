@tool
extends ZE_Base
class_name ZE_Zombie

@export var behavior: NodePath
@export var look_speed: float = 50.0
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

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var current_vel := root_3d.linear_velocity

	# Build target velocity
	var target_vel := movement_direction * move_speed
	target_vel.y = current_vel.y  # Preserve gravity

	# Blend toward target
	root_3d.linear_velocity = current_vel.lerp(target_vel, state.step)

	if not is_zero_approx(look_direction.length_squared()):
		look_follow(state, root_3d.global_transform, look_direction)


func set_look_direction(dir: Vector3) -> void:
	look_direction = dir # .normalized()
	look_direction.y = self.global_position.y

# Call this from your ZombieBehavior script
func set_movement_direction(dir: Vector3) -> void:
	movement_direction = dir.normalized()
	movement_direction.y = 0

func look_follow(state: PhysicsDirectBodyState3D, current_transform: Transform3D, target_position: Vector3) -> void:
	var forward_local_axis: Vector3 = Vector3.FORWARD
	var forward_dir: Vector3 = (current_transform.basis * forward_local_axis).normalized()
	var target_dir: Vector3 = (target_position - current_transform.origin).normalized()
	if not is_zero_approx(forward_dir.dot(target_dir)):
		var local_speed: float = clampf(look_speed, 0, acos(forward_dir.dot(target_dir)))
		root_3d.angular_velocity = local_speed * forward_dir.cross(target_dir) / state.step
