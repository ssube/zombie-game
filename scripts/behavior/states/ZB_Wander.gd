extends ZB_State
class_name ZB_State_Wander

@export var navigation_interval: float = 5.0
@export var wander_interval: float = 15.0
@export var wander_radius: float = 10.0
@export var point_proximity: float = 1.0

var navigation_path: PackedVector3Array = PackedVector3Array()
var navigation_timer: float = 0.0
var target_position: Vector3 = Vector3.ZERO
@onready var wander_timer: float = wander_interval

func tick(entity: Entity, delta: float, _blackboard: ZB_Blackboard) -> TickResult:
	if target_position == Vector3.ZERO:
		update_wander_target(entity)

	var node_3d := entity.root_3d as Node3D
	if NavigationUtils.is_point_nearby(node_3d, target_position, point_proximity):
		# update_wander_target(entity)
		return TickResult.CHECK

	# follow nav path
	var movement := entity.get_component(ZC_Movement) as ZC_Movement
	movement.target_look_position = target_position

	NavigationUtils.follow_navigation_path(node_3d, navigation_path, point_proximity)

	wander_timer -= delta
	if wander_timer > 0.0:
		return TickResult.CONTINUE

	print("Zombie wander timed out")
	update_wander_target(entity)
	return TickResult.CHECK

func update_wander_target(entity) -> void:
	var random_pos := NavigationUtils.pick_random_position(entity, wander_radius)
	print("Zombie picked new wander target position: ", random_pos)
	target_position = random_pos
	navigation_path = NavigationUtils.update_navigation_path(entity, target_position)
	wander_timer = wander_interval
