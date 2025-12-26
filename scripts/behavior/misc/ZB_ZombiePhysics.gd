extends Node
class_name ZB_ZombiePhysics


# Entity
@export var entity_body: RigidBody3D
@export var entity: ZE_Character


# Components
var entity_velocity: ZC_Velocity


func _update_components() -> void:
	entity_velocity = entity.get_component(ZC_Velocity)


func _lock_physics_body() -> void:
	# lock zombie node rotation
	entity_body.axis_lock_angular_x = true
	entity_body.axis_lock_angular_z = true


func on_ready() -> void:
	_lock_physics_body()
	_update_components()

	entity.action_event.connect(_on_action_event)

	print("Zombie ready")


# TODO: why is this being done here?
#func _process(delta: float) -> void:
#	if entity_velocity:
#		lerp_actor_velocity(Vector3.ZERO, delta)


## Gradually update the physics velocity of the actor node
#func lerp_actor_velocity(target_velocity: Vector3, delta: float) -> void:
#	var current_velocity: Vector3 = entity_velocity.linear_velocity
#	var new_velocity: Vector3 = current_velocity.lerp(target_velocity, minf(delta, 1.0))
#	if new_velocity.length_squared() < 1.0:
#		new_velocity = Vector3.ZERO
#
#	entity_velocity.linear_velocity = new_velocity


func _on_action_event(_entity: Entity, event: Enums.ActionEvent, _actor: Node):
	if event == Enums.ActionEvent.ENTITY_DEATH:
		# unlock rotation and let ragdoll physics take over
		entity_body.axis_lock_angular_x = false
		entity_body.axis_lock_angular_z = false
