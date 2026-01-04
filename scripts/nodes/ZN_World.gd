extends Node
class_name ZN_World

signal level_loading
signal level_loaded

@export var campaign: ZR_Campaign

@export_group("Start")
@export var start_level: String = ''
@export var start_marker: String = ''

@export_group("Debug")
@export var debug_skips_main_menu: bool = false
@export var debug_level: String = ''
@export var debug_marker: String = ''

@onready var last_level: String = start_level
@onready var last_spawn: String = start_marker

var current_level_name: String
var next_level_name: String
var deleted_entities: Array[String] = []


func _ready():
	campaign.cache()

	ECS.world = %World

	# Create the systems
	var system_root = %Systems
	for child in system_root.get_children():
		if child is System:
			ZombieLogger.info("Registering system: {0}", [child.get_path()])
			ECS.world.add_system(child)
		else:
			ZombieLogger.error("Child is not a system: {0}", [child.get_path()])

	# Create the observers
	var observer_root = %Observers
	for child in observer_root.get_children():
		if child is Observer:
			ZombieLogger.info("Registering observer: {0}", [child.get_path()])
			ECS.world.add_observer(child)
		else:
			ZombieLogger.error("Child is not an observer: {0}", [child.get_path()])

	# Create the root entities
	var entity_root = %Entities
	for child in entity_root.get_children():
		add_entity(child)

	var user_args := CommandLineArgs.parse_user_args()
	if CommandLineArgs.check_help(user_args):
		get_tree().quit()

	ZombieLogger.info("Running with user arguments: {0}", [JSON.stringify(user_args)])

	CommandLineArgs.load_mods_from_args(user_args)

	if user_args.get("merge_campaigns", false):
		campaign.merge_campaign(CommandLineArgs.get_campaign(user_args, campaign))
	else:
		campaign = CommandLineArgs.get_campaign(user_args, campaign)

	ZombieLogger.info("Loaded campaign: {0}", [campaign.title])

	if OS.is_debug_build() and debug_skips_main_menu:
		# look up debug level from CLI args
		var level_args := CommandLineArgs.get_debug_level(user_args, campaign, debug_level, debug_marker)
		load_level(level_args[0], level_args[1])
	else:
		# load_level(start_level, start_marker)
		%Menu.show_menu(ZM_BaseMenu.Menus.MAIN_MENU)

func _process(delta):
	# Process all systems
	if ECS.world:
		ECS.process(delta)

## Add the level entities to the ECS world
func _register_level_entities() -> void:
	var level_node = self.find_child("Level", false)
	if level_node == null:
		ZombieLogger.error("Missing level node!")
		return

	var level_entity_root = level_node.get_child(0).get_node("Entities")
	if level_entity_root == null:
		ZombieLogger.error("Level is missing Entities node!")

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
			ZombieLogger.warning("Remove null node from ECS: {0}", [entity])
			continue

		if entity.is_queued_for_deletion() or not entity.is_inside_tree():
			ZombieLogger.warning("Tried to remove invalid node: {0} {1} {2}", [entity, entity.is_queued_for_deletion(), entity.is_inside_tree()])
			continue

		if entity in keepers:
			continue

		ECS.world.remove_entity(entity)

	for child in %Level.get_children():
		%Level.remove_child(child)
		child.queue_free()


func load_next_level(spawn_point: String) -> void:
	assert(next_level_name != "", "Next level is missing!")
	load_level(next_level_name, spawn_point)


func load_level(level_name: String, spawn_point: String) -> void:
	# TODO: use ResourceLoader.load_threaded_get
	# var level_scene := ResourceLoader.load_threaded_get(level_path.resource_path) as PackedScene

	var level_data := campaign.get_level(level_name)
	if level_data == null:
		ZombieLogger.error("Invalid level name: {0}", [level_name])
		return

	ZombieLogger.debug("Loading level: {0}", [level_data.title])

	var level_hints := level_data.loading_hints.duplicate()
	if level_data.hint_mode == level_data.HintMode.APPEND:
		# TODO: make sure these don't accumulate over multiple level loads
		level_hints.append_array(campaign.hints)

	%Menu.set_hints(level_hints)
	%Menu.set_level(level_data.title, level_data.loading_image, level_data.end_image)
	%Menu.set_next_level(level_data.next_level)

	var level_scene = level_data.scene
	level_loading.emit(last_level, level_name)
	clear_world()

	var next_level := level_scene.instantiate()
	%Level.add_child(next_level)
	_register_level_entities()
	_register_level_objectives()

	if 'on_load' in next_level:
		next_level.on_load()

	if next_level is ZN_Level:
		var zn_level := next_level as ZN_Level
		zn_level.cache_markers()

	current_level_name = level_name
	next_level_name = level_data.next_level

	if level_data.min_load_time > 0:
		await get_tree().create_timer(level_data.min_load_time).timeout

	ECS.world._invalidate_cache("level_loaded")

	%Menu.push_action("Loaded level: %s" % level_data.title)
	level_loaded.emit(last_level, level_name)
	last_level = level_name

	var spawn_node := next_level.get_node(spawn_point) as Node3D
	last_spawn = spawn_point
	if spawn_point == "" or spawn_node == null:
		ZombieLogger.warning("Invalid spawn point: {0}", [spawn_point])
		spawn_node = next_level.get_node("Markers/Start") as Node3D
		last_spawn = "Markers/Start"

	if spawn_node == null:
		ZombieLogger.error("No fallback spawn point: Markers/Start")
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
		ZombieLogger.debug("Registering entity: {0}", [node.get_path()])
		ECS.world.add_entity(node)
	elif node is Node:
		for child in node.get_children():
			add_entity(child)
	else:
		ZombieLogger.warning("Child is not an entity: {0} {1}", [node.get_path(), node.get_class()])


func _register_level_objectives() -> void:
	ObjectiveManager.clear_objectives()

	var level_node = self.find_child("Level", false)
	if level_node == null:
		ZombieLogger.error("Missing level node!")
		return

	var level_objective_root = level_node.get_child(0).get_node("Objectives")
	if level_objective_root == null:
		ZombieLogger.error("Level is missing Objectives node!")
		return

	var objectives: Array[ZN_BaseObjective] = []
	for child in level_objective_root.get_children():
		if child is ZN_BaseObjective:
			objectives.append(child)

		ZombieLogger.info("Loading {0} root objectives", [objectives.size()])
	ObjectiveManager.set_objectives(objectives)
