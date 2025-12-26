@tool
extends ZE_Character
class_name ZE_Zombie

@export var physics: ZB_ZombiePhysics = null
@export var vision: ZB_ZombieVision = null

func on_ready():
	super.on_ready()
	physics.on_ready()
	vision.on_ready()
