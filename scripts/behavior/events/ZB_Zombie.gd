@icon("res://textures/icons/fsm_trigger.svg")
extends Node
class_name ZB_ZombieEvents

@export_group("Actor")
@export var actor_node: RigidBody3D

@export_group("Areas")
@export var vision_area: VisionCone3D
@export var attack_area: Area3D
@export var detection_area: Area3D

@export_group("States")
@export var blackboard: ZB_Blackboard
@export var state_machine: ZB_StateMachine
@export var state_attack: ZB_State_Attack
@export var state_chase: ZB_State_Chase
@export var state_wander: ZB_State_Wander

# Components
var actor_entity: Entity
var entity_health: ZC_Health
var entity_weapon: ZC_Weapon_Melee
var entity_velocity: ZC_Velocity

func _ready():
	if vision_area != null:
		vision_area.monitoring = true
		vision_area.body_sighted.connect(_on_vision_area_body_sighted)
		vision_area.body_hidden.connect(_on_vision_area_body_hidden)

	if attack_area != null:
		attack_area.monitoring = true
		attack_area.body_entered.connect(_on_attack_area_body_entered)
		attack_area.body_exited.connect(_on_attack_area_body_exited)

	if detection_area != null:
		detection_area.monitoring = true
		detection_area.body_entered.connect(_on_detection_area_body_entered)

	# lock zombie node rotation
	actor_node.axis_lock_angular_x = true
	actor_node.axis_lock_angular_z = true

	print("Zombie ready")

func on_ready(entity: Entity) -> void:
	actor_entity = entity
	entity_health = actor_entity.get_component(ZC_Health)
	entity_weapon = actor_entity.get_component(ZC_Weapon_Melee)
	entity_velocity = actor_entity.get_component(ZC_Velocity)

## Gradually update the physics velocity of the actor node
func lerp_actor_velocity(target_velocity: Vector3, delta: float) -> void:
	var current_velocity: Vector3 = entity_velocity.linear_velocity
	var new_velocity: Vector3 = current_velocity.lerp(target_velocity, minf(delta, 1.0))
	if new_velocity.length_squared() < 1.0:
		new_velocity = Vector3.ZERO

	entity_velocity.linear_velocity = new_velocity

func _process(delta: float):
	if not is_actor_active():
		state_machine.active = false
		# disable area monitoring for performance
		vision_area.debug_draw = false
		vision_area.monitoring = false
		attack_area.monitoring = false
		detection_area.monitoring = false
		# unlock rotation and let ragdoll physics take over
		actor_node.axis_lock_angular_x = false
		actor_node.axis_lock_angular_z = false
		# lerp to zero velocity
		lerp_actor_velocity(Vector3.ZERO, delta)
		# delete zombie weapon
		if actor_entity.current_weapon:
			EntityUtils.remove(actor_entity.current_weapon)
			actor_entity.current_weapon = null

		return

func _on_vision_area_body_sighted(body: Node) -> void:
	print("Zombie saw body: ", body.name)
	if EntityUtils.is_player(body):
		blackboard.set_value(BehaviorUtils.target_player, body)
		blackboard.set_value(BehaviorUtils.target_position, body.global_position)
		state_machine.set_state(state_chase.name)

func _on_vision_area_body_hidden(body: Node) -> void:
	print("Zombie lost sight of body: ", body.name)
	var target_player = blackboard.get_value(BehaviorUtils.target_player)
	if body == target_player:
		# clear target and continue wandering to the last known position
		blackboard.remove_value(BehaviorUtils.target_player)
		state_machine.set_state(state_wander.name)

func _on_attack_area_body_entered(body: Node) -> void:
	print("Zombie can attack body: ", body.name)
	if EntityUtils.is_player(body):
		blackboard.set_value(BehaviorUtils.target_player, body)
		state_machine.set_state(state_attack.name)

func _on_attack_area_body_exited(body: Node) -> void:
	print("Zombie can no longer attack body: ", body.name)
	var target_player = blackboard.get_value(BehaviorUtils.target_player)
	if body == target_player:
		# continue chasing
		state_machine.set_state(state_chase.name)

func _on_detection_area_body_entered(body: Node) -> void:
	print("Zombie detected body: ", body.name)
	var target_player = blackboard.get_value(BehaviorUtils.target_player)
	if EntityUtils.is_player(body) and target_player == null:
		blackboard.set_value(BehaviorUtils.target_position, body.global_position)

func is_actor_active() -> bool:
	if actor_entity and not entity_health:
		entity_health = actor_entity.get_component(ZC_Health)

	if entity_health == null:
		return false

	return entity_health.current_health > 0
