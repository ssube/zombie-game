extends Node

signal level_loading
signal level_loaded

@export var campaign: ZR_Campaign

@export_group("Start")
@export var start_level: String = ''
@export var start_marker: String = ''

@export_group("Debug")
@export var debug_level: String = ''
@export var debug_marker: String = ''

@onready var last_level: String = start_level

func _ready():
	campaign.cache()

	ECS.world = %World

	# Create the systems
	var system_root = %Systems
	for child in system_root.get_children():
		if child is System:
			print("Registering system: ", child.get_path())
			ECS.world.add_system(child)
		else:
			printerr("Child is not a system: ", child.get_path())

	# Create the observers
	var observer_root = %Observers
	for child in observer_root.get_children():
		if child is Observer:
			print("Registering observer: ", child.get_path())
			ECS.world.add_observer(child)
		else:
			printerr("Child is not an observer: ", child)

	# Create the root entities
	var entity_root = %Entities
	for child in entity_root.get_children():
		add_entity(child)

	var user_args := CommandLineArgs.parse_user_args()
	if CommandLineArgs.check_help(user_args):
		get_tree().quit()

	print("Running with user arguments: ", JSON.stringify(user_args))

	CommandLineArgs.load_mods_from_args(user_args)

	if user_args.get("merge_campaigns", false):
		campaign.merge_campaign(CommandLineArgs.get_campaign(user_args, campaign))
	else:
		campaign = CommandLineArgs.get_campaign(user_args, campaign)
	print("Loaded campaign: %s" % campaign.title)

	if OS.is_debug_build():
		# look up debug level from CLI args
		var level_args := CommandLineArgs.get_debug_level(user_args, campaign, debug_level, debug_marker)
		load_level(level_args[0], level_args[1])
	else:
		load_level(start_level, start_marker)

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
	# var level_scene := ResourceLoader.load_threaded_get(level_path.resource_path) as PackedScene

	var level_data := campaign.get_level(level_name)
	if level_data == null:
		printerr("Invalid level name: ", level_name)
		return

	print("Loading level: %s" % level_data.title)

	var level_hints := level_data.loading_hints.duplicate()
	if level_data.hint_mode == level_data.HintMode.APPEND:
		level_hints.append_array(campaign.hints)

	%Menu.set_hints(level_hints)
	%Menu.set_level(level_data.title, level_data.loading_image)

	var level_scene = level_data.scene
	level_loading.emit(last_level, level_name)
	clear_world()

	var next_level := level_scene.instantiate()
	if 'on_load' in next_level:
		next_level.on_load()

	%Level.add_child(next_level)
	_register_level_entities()
	_register_level_objectives()

	if level_data.min_load_time > 0:
		await get_tree().create_timer(level_data.min_load_time).timeout

	ECS.world._invalidate_cache("level_loaded")

	%Menu.push_action("Loaded level: %s" % level_name)
	level_loaded.emit(last_level, level_name)
	last_level = level_name

	var spawn_node := next_level.get_node(spawn_point) as Node3D
	if spawn_point == "" or spawn_node == null:
		printerr("Invalid spawn point: ", spawn_point)
		spawn_node = next_level.get_node("Markers/Start") as Node3D

	if spawn_node == null:
		printerr("No fallback spawn point: Markers/Start")
		return

	var players: Array[Entity] = QueryBuilder.new(ECS.world).with_all([ZC_Player]).execute()
	for player in players:
		var input := player.get_component(ZC_Input) as ZC_Input
		input.turn_direction = spawn_node.global_rotation

		var player3d := player.get_node(".") as Node3D
		player3d.global_position = spawn_node.global_position
		player3d.global_rotation = spawn_node.global_rotation


func add_entity(node: Node) -> void:
	if node is Entity:
		print("Registering entity: ", node)
		ECS.world.add_entity(node)
	elif node is Node:
		for child in node.get_children():
			add_entity(child)
	else:
		printerr("Child is not an entity: ", node.get_path(), node.get_class())


func _register_level_objectives() -> void:
	ObjectiveManager.clear_objectives()

	var level_node = self.find_child("Level", false)
	if level_node == null:
		printerr("Missing level node!")
		return

	var level_objective_root = level_node.get_child(0).get_node("Objectives")
	if level_objective_root == null:
		printerr("Level is missing Objectives node!")
		return

	var objectives: Array[ZN_BaseObjective] = []
	for child in level_objective_root.get_children():
		if child is ZN_BaseObjective:
			objectives.append(child)

	print("Loading %d root objectives" % objectives.size())
	ObjectiveManager.set_objectives(objectives)
