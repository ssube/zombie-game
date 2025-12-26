extends ZB_State
class_name ZB_State_Idle

@export var idle_interval: float = 5.0
@export var look_radius: float = 10.0

@onready var idle_timer = idle_interval
var look_direction = Vector3.ZERO

func enter(entity: Entity):
	idle_timer = idle_interval

	# turn towards random direction
	var node_3d := entity.root_3d as Node3D
	look_direction = NavigationUtils.pick_random_position(node_3d, look_radius)

func tick(entity: Entity, delta: float, _behavior: ZC_Behavior) -> TickResult:
	# print("Zombie is idling.")
	var entity3d := entity.get_node(".") as Node3D
	var movement := entity.get_component(ZC_Movement) as ZC_Movement
	movement.target_move_position = entity3d.global_position

	idle_timer -= delta
	if idle_timer <= 0.0:
		return TickResult.CHECK

	movement.target_look_position = look_direction

	# TODO: play a random idle animation
	return TickResult.CONTINUE
