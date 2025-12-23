@tool
extends ZE_Base
class_name ZE_Character

@export_group("Inventory")
@export var current_armor: ZE_Armor = null
@export var current_weapon: ZE_Weapon = null
@export var inventory_node: Node = null
@export var weapon_node: Node3D = null

@onready var rigid_3d := get_node(".") as RigidBody3D
@onready var static_3d := get_node(".") as StaticBody3D
@onready var root_3d := get_node(".") as Node3D

var look_tween: Tween
var move_tween: Tween

var max_look: float = deg_to_rad(180)

func on_ready() -> void:
	super.on_ready()

	if current_armor:
		self.add_relationship(RelationshipUtils.make_wearing(current_armor))

	if current_weapon:
		self.add_relationship(RelationshipUtils.make_equipped(current_weapon))

func _process(_delta: float) -> void:
	if current_weapon and weapon_node:
		current_weapon.global_transform = weapon_node.global_transform

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var movement: ZC_Movement = get_component(ZC_Movement)
	var velocity: ZC_Velocity = get_component(ZC_Velocity)
	if movement == null:
			return
	if velocity == null:
			return

	if rigid_3d != null:
		_apply_rigid_physics(delta, movement, velocity)

	if static_3d != null:
		_apply_static_physics(delta, movement, velocity)


func _apply_rigid_physics(_delta: float, movement: ZC_Movement, velocity: ZC_Velocity) -> void:
	_apply_rigid_movement_force(movement, velocity)
	_apply_rigid_look_torque(movement, velocity)


func _apply_rigid_movement_force(movement: ZC_Movement, velocity: ZC_Velocity) -> void:
	var current_vel := rigid_3d.linear_velocity
	var current_horizontal := Vector3(current_vel.x, 0, current_vel.z)

	# Read from velocity component, apply movement config
	var target_horizontal := velocity.linear_velocity * movement.move_speed * velocity.speed_multiplier
	target_horizontal.y = 0

	var velocity_diff := target_horizontal - current_horizontal
	var force := velocity_diff * rigid_3d.mass * movement.move_acceleration
	rigid_3d.apply_central_force(force)


func _apply_rigid_look_torque(movement: ZC_Movement, _velocity: ZC_Velocity) -> void:
	var current_transform := rigid_3d.global_transform
	var target_position := movement.target_look_position

	var forward_dir := -current_transform.basis.z
	var to_target := (target_position - current_transform.origin)
	to_target.y = 0

	if is_zero_approx(to_target.length_squared()):
		return

	to_target = to_target.normalized()
	forward_dir.y = 0
	forward_dir = forward_dir.normalized()

	var cross := forward_dir.cross(to_target)
	var dot := forward_dir.dot(to_target)
	var angle_diff := atan2(cross.y, dot)

	var desired_angular_vel := angle_diff * movement.look_speed
	var current_angular_vel := rigid_3d.angular_velocity.y
	var angular_diff := desired_angular_vel - current_angular_vel
	var torque_strength := angular_diff * rigid_3d.mass * movement.look_acceleration

	rigid_3d.apply_torque(Vector3(0, torque_strength, 0))


func _apply_static_physics(_delta: float, movement: ZC_Movement, velocity: ZC_Velocity) -> void:
	if movement.has_move_target:
		_apply_static_movement_tween(movement, velocity)

	if movement.has_look_target:
		_apply_static_look_tween(movement, velocity)


func _apply_static_movement_tween(movement: ZC_Movement, velocity: ZC_Velocity) -> void:
	if move_tween and move_tween.is_running():
		return

	# Calculate target velocity from components
	var target_velocity := velocity.linear_velocity * movement.move_speed * velocity.speed_multiplier
	target_velocity.y = 0

	if is_zero_approx(target_velocity.length_squared()):
		return

	# Duration based on speed - faster movement = shorter tween
	var movement_duration := 1.0 * maxf(target_velocity.length(), 0.5)
	movement_duration = clampf(movement_duration, 0.5, 5.0)

	move_tween = create_tween()
	move_tween.tween_property(root_3d, "global_position", target_velocity, movement_duration).as_relative()


func _apply_static_look_tween(movement: ZC_Movement, _velocity: ZC_Velocity) -> void:
	if look_tween and look_tween.is_running():
		return

	var current_transform := root_3d.global_transform
	var target_position := movement.target_look_position

	var look_transform := current_transform.looking_at(target_position, Vector3.UP, true)
	var look_rotation := look_transform.basis.get_euler()
	var current_rotation := current_transform.basis.get_euler()

	if is_zero_approx(current_rotation.distance_squared_to(look_rotation)):
		return

	# Compute yaw delta (Y axis rotation) and wrap it to +/- PI
	var delta_yaw := wrapf(look_rotation.y - current_rotation.y, -PI, PI)

	# Duration based on look_speed - higher speed = shorter tween
	var look_duration := absf(delta_yaw) / movement.look_speed
	look_duration = clampf(look_duration, 0.1, 1.0)

	look_tween = create_tween()
	look_tween.tween_property(root_3d, "rotation:y", delta_yaw, look_duration).as_relative()
