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

func tick(entity: Entity, delta: float, _blackboard: ZB_Blackboard) -> TickResult:
	# print("Zombie is idling.")
	entity.set_actor_velocity(Vector3.ZERO)

	idle_timer -= delta
	if idle_timer <= 0.0:
		return TickResult.CHECK

	entity.look_at_target(look_direction)
	# TODO: play a random idle animation
	return TickResult.CONTINUE
