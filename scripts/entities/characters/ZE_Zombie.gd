@tool
extends ZE_Character
class_name ZE_Zombie

@export var current_weapon: ZE_Weapon = null
@export var inventory_node: Node = null
@export var events: ZB_ZombieEvents = null

func on_ready():
	# Sync transform from scene to component
	var transform = get_component(ZC_Transform) as ZC_Transform
	if transform:
		transform.position = root_3d.global_position
		transform.rotation = root_3d.global_rotation

	if events:
		events.on_ready(self)
