extends Node

@onready var world: World = $"World"

func _ready():
	ECS.world = world

	# Create a moving player entity
	var e_player = $"World/Entities/Player"
	ECS.world.add_entity(e_player)  # Add to ECS world

	# Create the movement system
	var movement_system = %ZS_MovementSystem
	ECS.world.add_system(movement_system)

func _process(delta):
	# Process all systems
	if ECS.world:
		ECS.process(delta)
