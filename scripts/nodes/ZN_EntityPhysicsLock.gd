extends Node
class_name ZN_EntityPhysicsLock


# Entity
@export var entity_body: RigidBody3D
@export var entity: ZE_Character

@export var lock_x: bool = true
@export var lock_y: bool = false
@export var lock_z: bool = true

@export var unlock_on_death: bool = true


func _lock_physics_body() -> void:
	# lock node rotation
	
	if lock_x:
		entity_body.axis_lock_angular_x = true
		
	if lock_y:
		entity_body.axis_lock_angular_y = true
		
	if lock_z:
		entity_body.axis_lock_angular_z = true


func _ready() -> void:
	_lock_physics_body()

	entity.action_event.connect(_on_action_event)


func _on_action_event(_entity: Entity, event: Enums.ActionEvent, _actor: Node):
	if unlock_on_death and event == Enums.ActionEvent.ENTITY_DEATH:
		# unlock rotation and let ragdoll physics take over
		entity_body.axis_lock_angular_x = false
		entity_body.axis_lock_angular_y = false
		entity_body.axis_lock_angular_z = false
