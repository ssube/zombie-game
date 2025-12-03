extends System
class_name ZS_InputSystem

@export_range(0.0, 1.0) var turn_factor: float = 0.05
@export_range(0.0, 1.0) var max_lean: float = 0.2

func query():
	return q.with_all([ZC_Input])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var input = entity.get_component(ZC_Input) as ZC_Input

		input.move_direction = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")

		var turn_input = Input.get_vector("look_down", "look_up", "look_right", "look_left")
		turn_input *= turn_factor
		turn_input = turn_input.clampf(-turn_factor, +turn_factor)
		# print("turn input: ", turn_input)

		#input.turn_direction = Vector3.ZERO
		input.turn_direction.x = turn_input.x
		input.turn_direction.y = turn_input.y

		var leaning = false
		if Input.is_action_pressed("lean_right"):
			input.turn_direction.z -= turn_factor
			leaning = true
		if Input.is_action_pressed("lean_left"):
			input.turn_direction.z += turn_factor
			leaning = true

		if leaning:
			input.turn_direction.z = clampf(input.turn_direction.z, -max_lean, max_lean)
		else:
			input.turn_direction.z = 0

		input.game_pause = Input.is_action_just_pressed("game_pause")

		input.move_jump = Input.is_action_just_pressed("move_jump")
		input.move_crouch = Input.is_action_pressed("move_crouch")
		input.move_sprint = Input.is_action_pressed("move_sprint")

		input.use_attack = Input.is_action_just_pressed("use_attack")
		input.use_heal = Input.is_action_just_pressed("use_heal")
		input.use_interact = Input.is_action_just_pressed("use_interact")
		input.use_light = Input.is_action_just_pressed("use_light")

		input.weapon_next = Input.is_action_just_pressed("weapon_next")
		input.weapon_previous = Input.is_action_just_pressed("weapon_previous")
