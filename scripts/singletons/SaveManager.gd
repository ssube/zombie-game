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

	var level_data := serialize_level()
	game_data.levels["TODO: level key"] = level_data

	var player_data := serialize_players()
	game_data.players = player_data

	ResourceSaver.save(game_data, "user://saves/%s.tres" % name)

	return true


static func load_game(_name: String) -> bool:
	assert(false, "TODO: implement this")
	return true


static func serialize_component(component: Component) -> ZP_SavedComponent:
	var saved_component := ZP_SavedComponent.new()
	var component_script := component.get_script() as Script
	saved_component.type = component_script.get_global_name()
	saved_component.data = component.serialize()
	return saved_component


static func serialize_entity(entity: Entity) -> ZP_SavedEntity:
	var saved_entity := ZP_SavedEntity.new()

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
