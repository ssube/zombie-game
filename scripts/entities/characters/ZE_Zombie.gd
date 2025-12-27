@tool
extends ZE_Character
class_name ZE_Zombie

@export var vision: ZB_ZombieVision = null

func on_ready():
	super.on_ready()
	vision.on_ready()
