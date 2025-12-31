extends RigidBody3D
class_name ZN_Buoyant

@export var buoyancy_strength: float = 10
@export var target_height: float = 0.0
@export var use_starting_height: bool = true
@export var damping: float = 1
@export var angular_damping: float = 1
@export var max_velocity: float = 10.0

func _ready() -> void:
	if use_starting_height:
		target_height = self.global_position.y

func _physics_process(delta: float) -> void:
	var height_diff: float = target_height - self.global_position.y
	var buoyant_force: float = height_diff * buoyancy_strength
	buoyant_force = clamp(buoyant_force, -max_velocity, max_velocity)

	var damped_linear_velocity: Vector3 = self.linear_velocity.lerp(Vector3.ZERO, damping * delta)
	self.linear_velocity = damped_linear_velocity

	var damped_angular_velocity: Vector3 = self.angular_velocity.lerp(Vector3.ZERO, angular_damping * delta)
	self.angular_velocity = damped_angular_velocity

	self.apply_central_force(Vector3.UP * buoyant_force)
