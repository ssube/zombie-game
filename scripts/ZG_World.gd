extends Node

@onready var world: World = $"World"

func _ready():
	ECS.world = world

	# Create a moving player entity
	var e_player = $"World/Entities/Player"
	ECS.world.add_entity(e_player)  # Add to ECS world

	# Create the systems
	var system_root = %Systems
	for child in system_root.get_children():
		if child is System:
			ECS.world.add_system(child)

func _process(delta):
	# Process all systems
	if ECS.world:
		ECS.process(delta)
