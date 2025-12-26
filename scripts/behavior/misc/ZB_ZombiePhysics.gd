extends Node
class_name ZB_ZombiePhysics


# Entity
@export var entity_body: RigidBody3D
@export var entity: ZE_Character


func _lock_physics_body() -> void:
	# lock zombie node rotation
	entity_body.axis_lock_angular_x = true
	entity_body.axis_lock_angular_z = true


func on_ready() -> void:
	_lock_physics_body()

	entity.action_event.connect(_on_action_event)

	print("Zombie ready")
	

func _on_action_event(_entity: Entity, event: Enums.ActionEvent, _actor: Node):
	if event == Enums.ActionEvent.ENTITY_DEATH:
		# unlock rotation and let ragdoll physics take over
		entity_body.axis_lock_angular_x = false
		entity_body.axis_lock_angular_z = false
