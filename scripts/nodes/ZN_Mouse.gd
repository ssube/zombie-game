extends Node
class_name ZN_MouseInput

## Character root node
@export var character : CharacterBody3D

## Head node
@export var head : Node3D

## Settings
@export_group("Settings")

## Mouse settings
@export_subgroup("Mouse settings")

## Mouse sensitivity multiplier
@export_range(0.001, 0.010, 0.001) var degrees_per_unit: float = 0.002

## Pitch clamp settings
@export_subgroup("Clamp settings")

## Max pitch in degrees
@export_range(1, 90, 0.1) var max_pitch : float = 89

## Min pitch in degrees
@export_range(-90, -1, 0.1) var min_pitch : float = -89


func _ready():
	Input.set_use_accumulated_input(false)


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		aim_look(event)


## Handles aim look with the mouse.
func aim_look(event: InputEventMouseMotion) -> void:
	var viewport_transform: Transform2D = get_tree().root.get_final_transform()
	var motion: Vector2 = event.xformed_by(viewport_transform).relative

	motion *= OptionsManager.options.controls.mouse_sensitivity
	motion *= degrees_per_unit

	add_yaw(motion.x)
	add_pitch(motion.y)
	clamp_pitch()


## Rotates the character around the local Y axis by a given amount (in degrees) to achieve yaw.
func add_yaw(amount) -> void:
	if is_zero_approx(amount):
		return

	character.rotate_object_local(Vector3.DOWN, deg_to_rad(amount))
	character.orthonormalize()


## Rotates the head around the local x axis by a given amount (in degrees) to achieve pitch.
func add_pitch(amount) -> void:
	if is_zero_approx(amount):
		return

	head.rotate_object_local(Vector3.LEFT, deg_to_rad(amount))
	head.orthonormalize()


## Clamps the pitch between min_pitch and max_pitch.
func clamp_pitch() -> void:
	if head.rotation.x > deg_to_rad(min_pitch) and head.rotation.x < deg_to_rad(max_pitch):
		return

	head.rotation.x = clamp(head.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	head.orthonormalize()
