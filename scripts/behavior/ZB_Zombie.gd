extends Node
class_name ZB_Zombie

enum State {
	IDLE,
	CHASING,
	ATTACKING,
	WANDERING
}

@export_group("Actor")
@export var actor_node: Node3D
@export var actor_entity: Entity

@export_group("Behavior")
@export var starting_state: State = State.IDLE
@export var attack_cooldown: float = 5.0
@export var chase_timeout: float = 10.0
@export var navigation_interval: float = 1.0
@export var wander_radius: float = 10.0
@export var wander_interval: float = 15.0

@export_group("Areas")
@export var vision_area: VisionCone3D
@export var attack_area: Area3D
@export var detection_area: Area3D

@export_group("Movement")
@export var move_speed: float = 2.0
@export var force_multiplier: float = 1.0

@export_group("Navigation")
@export var point_proximity: float = 1.0

@onready var current_state := starting_state

var entity_health: ZC_Health
var attack_timer: float = 0.0
var idle_timer: float = 0.0
var navigation_timer: float = 0.0
var wander_timer: float = 0.0
var navigation_path: PackedVector3Array = PackedVector3Array()
var target_player: Node3D = null
var target_position: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO

func _ready():
	if vision_area != null:
		vision_area.monitoring = true
		vision_area.body_entered.connect(_on_vision_area_body_entered)
		vision_area.body_exited.connect(_on_vision_area_body_exited)

	if attack_area != null:
		attack_area.monitoring = true
		attack_area.body_entered.connect(_on_attack_area_body_entered)

	if detection_area != null:
		detection_area.monitoring = true
		detection_area.body_entered.connect(_on_detection_area_body_entered)

	if actor_entity != null:
		entity_health = actor_entity.get_component(ZC_Health)

	print("Zombie ready")

func _process(delta: float):
	update_timers(delta)

	if not is_actor_active():
		# disable area monitoring for performance
		vision_area.debug_draw = false
		vision_area.monitoring = false
		attack_area.monitoring = false
		detection_area.monitoring = false
		set_actor_velocity(Vector3.ZERO)
		return

	if current_state == State.IDLE:
		do_idle(delta)
	elif current_state == State.CHASING:
		do_chase(delta)
	elif current_state == State.ATTACKING:
		do_attack(delta)
	elif current_state == State.WANDERING:
		do_wander(delta)

func _physics_process(_delta: float) -> void:
	if actor_node is CharacterBody3D:
		if current_state == State.CHASING:
			actor_node.move_and_slide()
		elif current_state == State.WANDERING:
			actor_node.move_and_slide()
	elif actor_node is RigidBody3D:
		if not is_zero_approx(velocity.length()):
			actor_node.apply_force(velocity * force_multiplier)

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

func _on_detection_area_body_entered(body: Node) -> void:
	print("Zombie detected body: ", body.name)

func do_attack(_delta: float):
	if attack_timer > 0.0:
		return

	look_at_target(target_player.global_position)
	print("Zombie attacks player! ", target_player)

	var player_entity: Entity = target_player.get_node(".") as Entity
	# player_entity.add_component(ZC_Damage.new(10))
	player_entity.add_relationship(Relationship.new(ZC_Damaged.new(), ZC_Damage.new(10)))
	attack_timer = attack_cooldown

func do_idle(_delta: float):
	set_actor_velocity(Vector3.ZERO)

	if idle_timer > 0.0:
		# print("Zombie is idling.")
		# TODO: random idle animation
		# TODO: turn towards random direction
		return

	current_state = State.WANDERING

func do_wander(_delta: float):
	# print("Zombie is wandering.")
	if target_position == Vector3.ZERO or is_point_nearby(target_position, point_proximity):
		update_wander_target()

	# follow nav path
	follow_navigation_path()

	if wander_timer > 0.0:
		return

	wander_timer = wander_interval
	update_wander_target()
	print("Zombie wander timed out, picked new target position: ", target_position)

func do_chase(_delta: float):
	if target_player == null:
		current_state = State.WANDERING
		return

	target_position = target_player.global_position
	# print("Zombie is chasing player at position: ", target_position)

	follow_navigation_path()
	update_navigation_path(actor_node.global_position, target_position)

func follow_navigation_path() -> void:
	if len(navigation_path) == 0:
		return

	var next_point := navigation_path[0]
	if is_point_nearby(next_point, point_proximity):
		navigation_path.remove_at(0)
	else:
		move_to_target(next_point, target_position)

func update_wander_target() -> void:
	var random_pos := pick_random_position(actor_node.global_position)
	print("Zombie picked new wander target position: ", random_pos)
	target_position = random_pos
	navigation_path.clear()
	update_navigation_path(actor_node.global_position, target_position)

func look_at_target(look_target_pos: Vector3) -> void:
	# rotate to face target
	var look_pos := Vector3(look_target_pos.x, actor_node.global_position.y, look_target_pos.z)
	if not is_zero_approx((look_pos - actor_node.global_position).length()):
		actor_node.look_at(look_pos)

func move_to_target(target_pos: Vector3, look_target_pos: Vector3) -> void:
	# print("Zombie moving to target position: ", target_pos)
	look_at_target(look_target_pos)

	# move toward target
	var target_offset: Vector3 = target_pos - actor_node.global_position
	target_offset = target_offset.normalized() * move_speed
	set_actor_velocity(target_offset)

func set_actor_velocity(target_velocity: Vector3) -> void:
	if actor_node is RigidBody3D:
		velocity = target_velocity
	elif actor_node is CharacterBody3D:
		actor_node.velocity = target_velocity
	else:
		printerr("Unknown actor type: ", actor_node.get_class())

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
