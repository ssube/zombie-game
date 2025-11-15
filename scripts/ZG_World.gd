extends Node

func _ready():
	ECS.world = %World

	# Create the entities
	var entity_root = %Entities
	for child in entity_root.get_children():
		if child is Entity:
			ECS.world.add_entity(child)
		else:
			printerr("Child is not an entity: ", child.get_path())

	# Create the systems
	var system_root = %Systems
	for child in system_root.get_children():
		if child is System:
			ECS.world.add_system(child)
		else:
			printerr("Child is not a system: ", child.get_path())

func _process(delta):
	# Process all systems
	if ECS.world:
		ECS.process(delta)
