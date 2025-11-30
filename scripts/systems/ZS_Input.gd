extends System
class_name ZS_InputSystem

func query():
	return q.with_all([ZC_Input])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var input = entity.get_component(ZC_Input) as ZC_Input

		input.move_direction = Vector2.ZERO
		if Input.is_action_pressed("move_backward"):
			input.move_direction.y -= 1
		if Input.is_action_pressed("move_forward"):
			input.move_direction.y += 1
		if Input.is_action_pressed("move_left"):
			input.move_direction.x -= 1
		if Input.is_action_pressed("move_right"):
			input.move_direction.x += 1

		input.move_direction = input.move_direction.normalized()

		if Input.is_action_pressed("look_right"):
			input.turn_direction.y -= 0.1
		if Input.is_action_pressed("look_left"):
			input.turn_direction.y += 0.1
		if Input.is_action_pressed("look_up"):
			input.turn_direction.x += 0.1
		if Input.is_action_pressed("look_down"):
			input.turn_direction.x -= 0.1

		if Input.is_action_pressed("lean_right"):
			input.turn_direction.z = -0.25
		elif Input.is_action_pressed("lean_left"):
			input.turn_direction.z = +0.25
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