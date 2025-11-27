extends Node
class_name ZB_Zombie

enum State {
	IDLE,
	CHASING,
	ATTACKING,
	WANDERING
}

@export var actor: Node3D

@export_group("Behavior")
@export var starting_state: State = State.IDLE
@export var attack_cooldown: float = 5.0
@export var chase_timeout: float = 10.0
@export var navigation_interval: float = 1.0
@export var wander_radius: float = 10.0
@export var wander_interval: float = 5.0

@export_group("Areas")
@export var vision_area: Area3D
@export var attack_area: Area3D
@export var detection_area: Area3D

@onready var current_state := starting_state

var attack_timer: float = 0.0
var nav_timer: float = 0.0
var nav_path: PackedVector3Array = PackedVector3Array()
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

	if detection_area != null:
		detection_area.monitoring = true
		detection_area.body_entered.connect(_on_detection_area_body_entered)

	print("Zombie ready")

func _process(delta: float):
	if current_state == State.IDLE:
		do_idle(delta)
	elif current_state == State.CHASING:
		do_chase(delta)
	elif current_state == State.ATTACKING:
		do_attack(delta)
	elif current_state == State.WANDERING:
		do_wander(delta)

func _on_vision_area_body_entered(body: Node) -> void:
	print("Zombie saw body: ", body.name)
	if is_player(body):
		target_player = body as Node3D
		target_position = target_player.global_position
		current_state = State.CHASING

func _on_vision_area_body_exited(body: Node) -> void:
	print("Zombie lost sight of body: ", body.name)
	if body == target_player:
		target_player = null
		current_state = State.WANDERING

func _on_attack_area_body_entered(body: Node) -> void:
	print("Zombie can attack body: ", body.name)
	if is_player(body):
		target_player = body as Node3D
		current_state = State.ATTACKING

func _on_detection_area_body_entered(body: Node) -> void:
	print("Zombie detected body: ", body.name)

func do_attack(delta: float):
	if attack_timer > 0.0:
		attack_timer -= delta
		return

	print("Zombie attacks player! ", target_player)
	attack_timer = attack_cooldown

func do_idle(delta: float):
	pass # print("Zombie is idling.")

func do_wander(delta: float):
	print("Zombie is wandering.")

func do_chase(delta: float):
	if target_player == null:
		current_state = State.WANDERING
		return

	target_position = target_player.global_position
	print("Zombie is chasing player at position: ", target_position)

	if len(nav_path) > 0:
		var next_point := nav_path[0]
		var proximity: float = actor.global_position.distance_to(next_point)
		if proximity < 1.0:
			nav_path.remove_at(0)
		else:
			print("Zombie moving to next nav point: ", next_point)
			move_to_target(next_point)

	if nav_timer > 0.0:
		nav_timer -= delta
		return

	var success := update_navigation_path(actor.global_position, target_position)
	nav_timer = navigation_interval
	if success:
		print("Zombie got new navigation path with ", len(nav_path), " points.")
	else:
		print("Zombie failed to update navigation path.")

func move_to_target(target_pos: Vector3) -> void:
	print("Zombie moving to target position: ", target_pos)
	var target_offset: Vector3 = target_pos - actor.global_position

	if actor is RigidBody3D:
		actor.apply_force(target_offset)
	elif actor is CharacterBody3D:
		actor.velocity = target_offset
		# actor.move_and_slide()
		# print("TODO: move character by: ", actor.velocity)
	else:
		printerr("Unknown actor type: ", actor.get_class())


func is_player(body: Node) -> bool:
	if body is Entity:
		return body.has_component(ZC_Player)
	return false

func update_navigation_path(nav_start_position: Vector3, nav_target_position: Vector3) -> bool:
	if actor == null:
		return false

	if not actor.is_inside_tree():
		return false

	var default_map_rid: RID = actor.get_world_3d().get_navigation_map()
	nav_path = NavigationServer3D.map_get_path(
		default_map_rid,
		nav_start_position,
		nav_target_position,
		true
	)

	if len(nav_path) == 0:
		return false

	return true
