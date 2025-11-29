extends Node
class_name ZB_Zombie

enum State {
	IDLE,
	CHASING,
	ATTACKING,
	WANDERING
}

@export_group("Actor")
@export var actor_node: RigidBody3D

@export_group("Behavior")
@export var starting_state: State = State.IDLE

@export_subgroup("Chasing")
@export var chase_timeout: float = 10.0

@export_subgroup("Wandering")
@export var wander_radius: float = 10.0
@export var wander_interval: float = 15.0

@export_group("Areas")
@export var vision_area: VisionCone3D
@export var attack_area: Area3D
@export var detection_area: Area3D

@export_group("Movement")
@export var move_speed: float = 2.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0
@export var force_multiplier: float = 1.0

@export_group("Navigation")
@export var navigation_interval: float = 1.0
@export var point_proximity: float = 1.0

@onready var current_state := starting_state

# Components
var actor_entity: Entity
var entity_health: ZC_Health
var entity_weapon: ZC_Weapon_Melee
var entity_velocity: ZC_Velocity

# Timers
var attack_timer: float = 0.0
var idle_timer: float = 0.0
var navigation_timer: float = 0.0
var wander_timer: float = 0.0

# Movement
var navigation_path: PackedVector3Array = PackedVector3Array()
var target_player: Node3D = null
var target_position: Vector3 = Vector3.ZERO

func _ready():
	if vision_area != null:
		vision_area.monitoring = true
		vision_area.body_entered.connect(_on_vision_area_body_entered)
		vision_area.body_exited.connect(_on_vision_area_body_exited)

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

func _process(delta: float):
	update_timers(delta)

	if false: # not is_actor_active():
		# disable area monitoring for performance
		vision_area.debug_draw = false
		vision_area.monitoring = false
		attack_area.monitoring = false
		detection_area.monitoring = false
		set_actor_velocity(Vector3.ZERO)
		return

	if current_state == State.IDLE:
		do_idle()
	elif current_state == State.CHASING:
		do_chase()
	elif current_state == State.ATTACKING:
		do_attack()
	elif current_state == State.WANDERING:
		do_wander()

func _on_vision_area_body_entered(body: Node) -> void:
	print("Zombie saw body: ", body.name)
	if is_body_player(body):
		target_player = body as Node3D
		target_position = target_player.global_position
		current_state = State.CHASING

func _on_vision_area_body_exited(body: Node) -> void:
	print("Zombie lost sight of body: ", body.name)
	if body == target_player:
		# clear target and continue wandering to the last known position
		target_player = null
		current_state = State.WANDERING

func _on_attack_area_body_entered(body: Node) -> void:
	print("Zombie can attack body: ", body.name)
	if is_body_player(body):
		target_player = body as Node3D
		current_state = State.ATTACKING

func _on_attack_area_body_exited(body: Node) -> void:
	print("Zombie can no longer attack body: ", body.name)
	if body == target_player:
		# continue chasing
		current_state = State.CHASING

func _on_detection_area_body_entered(body: Node) -> void:
	print("Zombie detected body: ", body.name)

func do_attack():
	look_at_target(target_player.global_position)

	if attack_timer > 0.0:
		return

	print("Zombie attacks player! ", target_player)

	var player_entity: Entity = target_player.get_node(".") as Entity
	player_entity.add_relationship(RelationshipUtils.add_damage(entity_weapon.damage))
	attack_timer = entity_weapon.cooldown_time

func do_idle():
	print("Zombie is idling.")
	set_actor_velocity(Vector3.ZERO)

	if idle_timer > 0.0:
		# TODO: random idle animation
		# TODO: turn towards random direction
		return

	current_state = State.WANDERING

func do_wander():
	print("Zombie is wandering.")
	if target_position == Vector3.ZERO or is_point_nearby(target_position, point_proximity):
		update_wander_target()

	# follow nav path
	look_at_target(target_position)
	follow_navigation_path()

	if wander_timer > 0.0:
		return

	wander_timer = wander_interval
	update_wander_target()
	print("Zombie wander timed out, picked new target position: ", target_position)

func do_chase():
	if target_player == null:
		current_state = State.WANDERING
		return

	target_position = target_player.global_position
	print("Zombie is chasing player at position: ", target_position)

	look_at_target(target_position)
	update_navigation_path(actor_node.global_position, target_position)
	follow_navigation_path()

func follow_navigation_path() -> void:
	if len(navigation_path) == 0:
		return

	var next_point := navigation_path[0]
	if is_point_nearby(next_point, point_proximity):
		navigation_path.remove_at(0)
	else:
		move_to_target(next_point)

func update_wander_target() -> void:
	var random_pos := pick_random_position(actor_node.global_position)
	print("Zombie picked new wander target position: ", random_pos)
	target_position = random_pos
	update_navigation_path(actor_node.global_position, target_position)

func look_at_target(look_target_position: Vector3) -> void:
	# rotate to face target
	# var target_offset: Vector3 = look_target_position - actor_node.global_position
	# if not is_zero_approx(target_offset.length_squared()):
	actor_node.set_look_direction(look_target_position)

func move_to_target(move_target_position: Vector3) -> void:
	# move toward target
	var target_offset: Vector3 = move_target_position - actor_node.global_position
	target_offset = target_offset.normalized() * move_speed * entity_velocity.speed_modifier
	set_actor_velocity(target_offset)

func set_actor_velocity(target_velocity: Vector3) -> void:
	if is_zero_approx(target_velocity.length_squared()):
		return

	# print("Setting actor velocity to: ", target_velocity)
	actor_node.set_movement_direction(target_velocity)

func is_actor_active() -> bool:
	if actor_entity:
		entity_health = actor_entity.get_component(ZC_Health)

	if entity_health == null:
		return false

	return entity_health.current_health > 0

func is_body_player(body: Node) -> bool:
	if body is Entity:
		return body.has_component(ZC_Player)
	return false

func is_point_nearby(point: Vector3, proximity: float) -> bool:
	if actor_node == null:
		return false

	var distance: float = actor_node.global_position.distance_to(point)
	return distance <= proximity

func update_timers(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
	if idle_timer > 0.0:
		idle_timer -= delta
	if navigation_timer > 0.0:
		navigation_timer -= delta
	if wander_timer > 0.0:
		wander_timer -= delta

func update_navigation_path(nav_start_position: Vector3, nav_target_position: Vector3) -> bool:
	if navigation_timer > 0.0:
		return false

	if actor_node == null:
		return false

	if not actor_node.is_inside_tree():
		return false

	var default_map_rid: RID = actor_node.get_world_3d().get_navigation_map()
	navigation_path = NavigationServer3D.map_get_path(
		default_map_rid,
		nav_start_position,
		nav_target_position,
		true
	)
	navigation_timer = navigation_interval

	if len(navigation_path) == 0:
		return false

	return true

## Get a random position on the navigation map within wander_radius of origin
func pick_random_position(origin: Vector3) -> Vector3:
	var random_x := randf_range(origin.x - wander_radius, origin.x + wander_radius)
	var random_z := randf_range(origin.z - wander_radius, origin.z + wander_radius)
	var random_point: Vector3 = Vector3(random_x, origin.y, random_z)

	var default_map_rid: RID = actor_node.get_world_3d().get_navigation_map()

	return NavigationServer3D.map_get_closest_point(
		default_map_rid,
		random_point
	)
