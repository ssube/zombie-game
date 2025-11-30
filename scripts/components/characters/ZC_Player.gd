extends Component
class_name ZC_Player

@export var view_ray: NodePath = '.'
@export var held_keys: Array[String] = []

func add_key(key_name: String):
	if key_name not in held_keys:
		held_keys.append(key_name)

func has_key(key_name: String) -> bool:
	return key_name in held_keys
