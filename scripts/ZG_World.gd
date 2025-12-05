extends Node

signal level_loading
signal level_loaded

@export var level_scenes: Dictionary[String, Resource] = {}
@export var start_level: String = ''
@onready var last_level: String = start_level

func _ready():
	ECS.world = %World

	# Create the systems
	var system_root = %Systems
	for child in system_root.get_children():
		if child is System:
			ECS.world.add_system(child)
		else:
			printerr("Child is not a system: ", child.get_path())

	# Create the observers
	var observer_root = %Observers
	for child in observer_root.get_children():
		if child is Observer:
			ECS.world.add_observer(child)
		else:
			printerr("Child is not an observer: ", child)

	# Create the root entities
	var entity_root = %Entities
	for child in entity_root.get_children():
		add_entity(child)

	_register_level_entities()

func _process(delta):
	# Process all systems
	if ECS.world:
		ECS.process(delta)

## Add the level entities to the ECS world
func _register_level_entities() -> void:
	var level_node = self.find_child("Level", false)
	if level_node == null:
		printerr("Missing level node!")
		return

	var level_entity_root = level_node.get_child(0).get_node("Entities")
	if level_entity_root == null:
		printerr("Level is missing Entities node!")

	for child in level_entity_root.get_children():
		add_entity(child)
		if "inventory_node" in child:
			var items = child.inventory_node.get_children()
			for item in items:
				if item is Entity:
					ECS.world.add_entity(item)


func clear_world(keep_players: bool = true) -> void:
	var keepers: Array[Entity] = []

	if keep_players:
		var players: Array[Entity] = QueryBuilder.new(ECS.world).with_all([ZC_Player]).execute()
		keepers.append_array(players)
		for player: ZE_Player in players:
			keepers.append_array(player.get_inventory())
			var weapon = player.current_weapon
			if weapon != null:
				keepers.append(weapon)

	var entity_list := ECS.world.entities.duplicate()
	for entity in entity_list:
		if entity == null:
			printerr("Remove null node from ECS: ", entity)
			continue

		if entity.is_queued_for_deletion() or not entity.is_inside_tree():
			printerr("Tried to remove invalid node: ", entity, entity.is_queued_for_deletion(), entity.is_inside_tree())
			continue

		if entity in keepers:
			continue

		ECS.world.remove_entity(entity)

	for child in %Level.get_children():
		%Level.remove_child(child)
		child.queue_free()


func load_level(level_name: String, spawn_point: String) -> void:
	# TODO: use ResourceLoader.load_threaded_get

	var level_scene = level_scenes.get(level_name) as PackedScene
	if level_scene == null:
		printerr("Invalid level name: ", level_name)
		return

	level_loading.emit(last_level, level_name)
	clear_world()

	# var level_scene := ResourceLoader.load_threaded_get(level_path.resource_path) as PackedScene
	var next_level := level_scene.instantiate()

	%Level.add_child(next_level)
	_register_level_entities()

	%Hud.push_action("Loaded level: %s" % level_name)
	level_loaded.emit(last_level, level_name)
	last_level = level_name

	var spawn_node := next_level.get_node(spawn_point) as Node3D
	if spawn_node == null:
		printerr("Invalid spawn point: ", spawn_point)
		return

	var players: Array[Entity] = QueryBuilder.new(ECS.world).with_all([ZC_Player]).execute()
	for player in players:
		var transform := player.get_component(ZC_Transform) as ZC_Transform
		transform.position = spawn_node.global_position
		transform.rotation = spawn_node.global_rotation

		var input := player.get_component(ZC_Input) as ZC_Input
		input.turn_direction = spawn_node.global_rotation

		var player3d := player.get_node(".") as Node3D
		player3d.global_position = spawn_node.global_position
		player3d.global_rotation = spawn_node.global_rotation


func add_entity(node: Node) -> void:
	if node is Entity:
		ECS.world.add_entity(node)
	elif node is Node3D:
		printerr("Entities within Node3D children will not be added: ", node.get_path())
	elif node is Node:
		for child in node.get_children():
			add_entity(child)
	else:
		printerr("Child is not an entity: ", node.get_path(), node.get_class())
