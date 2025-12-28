class_name SaveManager


static var save_version: int = 1


# var _deleted: Array[String] = []


static func create_path() -> bool:
	var user_dir := DirAccess.open("user://")
	if not user_dir.dir_exists("saves"):
		user_dir.make_dir("saves")

	return true


## Sort by time, or if the times are equal, by name
## Inputs should be a 2-value array with [name, time]
static func _sort_by_time_name(a, b):
	if a[1] == b[1]:
		return a[0] < b[0]

	# latest first
	return a[1] > b[1]


static func _sort_values(data: Dictionary) -> Array:
	var sorted_pairs = []
	for key in data.keys():
		sorted_pairs.append([key, data[key]])

	sorted_pairs.sort_custom(_sort_by_time_name)
	return sorted_pairs


static func list_saves() -> Array[String]:
	SaveManager.create_path()
	var save_dir: DirAccess = DirAccess.open("user://saves")
	var save_names: Dictionary[String, int] = {}

	save_dir.list_dir_begin()
	var file_name = save_dir.get_next()
	while file_name != "":
		if save_dir.current_is_dir():
			printerr("Nested save folders are not supported!")
		else:
			print("Found save: ", file_name)
			var clean_name = file_name.replace("_entities.tres", "").replace("_objectives.tres", "").replace(".tres", "")
			var modified_at = FileAccess.get_modified_time("user://saves/" + file_name)
			save_names[clean_name] = modified_at

		file_name = save_dir.get_next()

	# sort by modified time
	var sorted_saves := _sort_values(save_names)
	var sorted_names: Array[String] = []

	for pair in sorted_saves:
		sorted_names.append(pair[0])

	return sorted_names


static func save_game(name: String) -> bool:
	SaveManager.create_path()

	# TODO: merge with any previous level data
	var game_data := ZP_SavedGame.new()
	game_data.version = SaveManager.save_version

	var game_node := TreeUtils.get_game(root)
	var level_name := game_node.current_level_name
	game_data.current_level = level_name
	game_data.last_spawn = game_node.last_spawn

	var level_data := serialize_level()
	game_data.levels[level_name] = level_data

	var player_data := serialize_players()
	game_data.players = player_data

	ResourceSaver.save(game_data, "user://saves/%s.tres" % name)

	return true


static func load_game(name: String, root: Node, use_json: bool = true) -> bool:
	if use_json:
		return false
		# return load_game_json(name, root)
	else:
		return load_game_resource(name, root)


static func load_game_resource(name: String, root: Node) -> bool:
	var game_data := ResourceLoader.load("user://saves/%s.tres" % name, "ZP_SavedGame") as ZP_SavedGame
	if game_data == null:
		printerr("Failed to load save game: ", name)
		return false

	_cache_components()

	var game := TreeUtils.get_game(root)
	game.clear_world()
	game.load_level(game_data.current_level, game_data.last_spawn)

	var level_data := game_data.levels.get(game_data.current_level, null) as ZP_SavedLevel
	if level_data == null:
		printerr("No saved data for level: ", game_data.current_level)
		return false

	deserialize_level(level_data)
	deserialize_players(game_data.players, root.get_node("World/Entities"))

	return true


static var _component_cache: Dictionary[String, String] = {}


static func _cache_components() -> void:
	_component_cache.clear()

	var global_classes := ProjectSettings.get_global_class_list()
	for class_info in global_classes:
		var name: String = class_info.get("class")
		var path: String = class_info.get("path")
		if name.begins_with("ZC_"):
			_component_cache[name] = path


static func serialize_component(component: Component) -> ZP_SavedComponent:
	var saved_component := ZP_SavedComponent.new()
	var component_script := component.get_script() as Script
	saved_component.type = component_script.get_global_name()
	saved_component.data = component.serialize()
	return saved_component


static func serialize_entity(entity: Entity) -> ZP_SavedEntity:
	var saved_entity := ZP_SavedEntity.new()
	saved_entity.id = entity.id

	if entity is ZE_Base:
		saved_entity.prefab_path = entity.prefab_path

	if entity.get_node(".") is Node3D:
		saved_entity.transform = entity.global_transform

	# serialize components
	for component in entity.components.values():
		saved_entity.components.append(serialize_component(component))

	# serialize inventory
	if "inventory_node" in entity:
		for item in entity.inventory_node.get_children():
			saved_entity.inventory.append(serialize_entity(item))

	# serialize relationships
	for rel in entity.relationships:
		saved_entity.relationships.append(serialize_relationship(rel))

	return saved_entity


static func serialize_relationship(relationship: Relationship) -> ZP_SavedRelationship:
	var saved_relationship := ZP_SavedRelationship.new()
	saved_relationship.relation = serialize_component(relationship.relation)
	if relationship.target is Entity:
		saved_relationship.target_type = ZP_SavedRelationship.TargetType.ENTITY
		saved_relationship.target_entity_id = relationship.target_entity.id
	else:
		saved_relationship.target_type = ZP_SavedRelationship.TargetType.COMPONENT
		saved_relationship.target_entity_id = ""
		saved_relationship.target_component = serialize_component(relationship.target)

	return saved_relationship


static func serialize_level() -> ZP_SavedLevel:
	var saved_level := ZP_SavedLevel.new()

	for entity in ECS.world.query.with_all([ZC_Persistent]).execute():
		saved_level.entities[entity.id] = serialize_entity(entity)

	saved_level.objectives = ObjectiveManager.save()

	# TODO: include deleted entities

	return saved_level


static func serialize_players() -> Dictionary[String, ZP_SavedEntity]:
	var saved_players: Dictionary[String, ZP_SavedEntity] = {}

	for player in EntityUtils.get_players():
		saved_players[player.id] = serialize_entity(player)

	return saved_players


static func deserialize_component(saved_component: ZP_SavedComponent) -> Component:
	var component: Component = null
	if saved_component.type in _component_cache:
		var script_path: String = _component_cache[saved_component.type]
		var script: Script = load(script_path)
		component = script.new()
		for key in saved_component.data.keys():
			component[key] = saved_component.data[key]
	else:
		printerr("Unknown component type during deserialization: ", saved_component.type)

	return component


static func _get_or_create_entity(saved_entity: ZP_SavedEntity) -> Entity:
	var entity := ECS.world.get_entity_by_id(saved_entity.id)
	if entity == null:
		# TODO: load the prefab if prefab_path is set
		assert(saved_entity.prefab_path != "", "Prefab path is empty, cannot load entity prefab")
		var prefab := ResourceLoader.load(saved_entity.prefab_path) as PackedScene
		if prefab == null:
			printerr("Failed to load prefab at path: ", saved_entity.prefab_path)

		entity = prefab.instantiate() as Entity
		entity.id = saved_entity.id
		ECS.world.add_entity(entity)

	return entity


static func deserialize_entity(saved_entity: ZP_SavedEntity) -> Entity:
	var entity := _get_or_create_entity(saved_entity)

	if saved_entity.transform != Transform3D.IDENTITY:
		if entity.get_node(".") is Node3D:
			entity.global_transform = saved_entity.transform

	# deserialize components
	for saved_component in saved_entity.components:
		var component := deserialize_component(saved_component)
		if component != null:
			entity.add_component(component)

	# deserialize inventory
	if "inventory_node" in entity:
		for saved_item in saved_entity.inventory:
			var item_entity := deserialize_entity(saved_item)
			entity.inventory_node.add_child(item_entity)

	# deserialize relationships after all entities are created

	return entity


static func deserialize_relationship(saved_relationship: ZP_SavedRelationship, entity_lookup: Dictionary[String, Entity]) -> Relationship:
	var relationship := Relationship.new()
	relationship.relation = deserialize_component(saved_relationship.relation)
	if saved_relationship.target_type == ZP_SavedRelationship.TargetType.ENTITY:
		if saved_relationship.target_entity_id in entity_lookup:
			relationship.target = entity_lookup[saved_relationship.target_entity_id]
		else:
			printerr("Unknown target entity ID during relationship deserialization: ", saved_relationship.target_entity_id)
	else:
		relationship.target = deserialize_component(saved_relationship.target_component)

	return relationship


static func deserialize_level(saved_level: ZP_SavedLevel) -> void:
	# TODO: add all entities, even existing ones
	var entity_lookup: Dictionary[String, Entity] = {}

	# First pass: create all entities
	for entity_id in saved_level.entities.keys():
		var saved_entity := saved_level.entities[entity_id]
		var entity := deserialize_entity(saved_entity)
		entity.id = entity_id
		entity_lookup[entity_id] = entity
		EntityUtils.upsert(entity)

	# Handle deleted entities
	for deleted_id in saved_level.deleted:
		var entity := ECS.world.get_entity_by_id(deleted_id)
		if entity != null:
			ECS.world.remove_entity(entity)

	# Second pass: set up relationships
	for entity_id in saved_level.entities.keys():
		var saved_entity := saved_level.entities[entity_id]
		var entity := ECS.world.get_entity_by_id(entity_id)
		for saved_relationship in saved_entity.relationships:
			var relationship := deserialize_relationship(saved_relationship, entity_lookup)
			entity.add_relationship(relationship)

	ObjectiveManager.load(saved_level.objectives)


static func deserialize_players(saved_players: Dictionary[String, ZP_SavedEntity], entity_node: Node) -> void:
	for player_id in saved_players.keys():
		var saved_entity := saved_players[player_id]
		var entity := deserialize_entity(saved_entity)
		entity.id = player_id
		entity_node.add_child(entity)
		EntityUtils.upsert(entity)
