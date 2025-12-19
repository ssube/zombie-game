@tool
extends ZE_Character
class_name ZE_Zombie

@export var events: ZB_ZombieEvents = null

func on_ready():
	super.on_ready()
	if events:
		events.on_ready(self)
