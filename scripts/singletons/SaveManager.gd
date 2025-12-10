class_name SaveManager


static func create_path() -> bool:
	var user_dir := DirAccess.open("user://")
	if not user_dir.dir_exists("saves"):
		user_dir.make_dir("saves")

	return true


static func _sort_by_value(a, b):
	return a[1] < b[1]


static func _sort_values(data: Dictionary) -> Array[Array]:
	var sorted_pairs = []
	for key in data.keys():
		sorted_pairs.append([key, data[key]])

	sorted_pairs.sort_custom(_sort_by_value)
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
			var modified_at = FileAccess.get_modified_time(file_name)
			save_names[clean_name] = modified_at

		file_name = save_dir.get_next()

	# TODO: sort by modified time
	save_names.sort()
	return save_names.keys()


static func save_game(name: String) -> bool:
	SaveManager.create_path()

	# save ECS world
	var query = ECS.world.query.with_all([C_Persistent])
	var data = ECS.serialize(query)

	if ECS.save(data, "user://saves/%s_entities.tres" % name):
		print("Saved %d entities!" % data.entities.size())

	# save objectives
	if ObjectiveManager.save("user://saves/%s_objectives.tres" % name):
		print("Saved %d objectives!" % ObjectiveManager.objectives.size())

	return true


static func load_game(_name: String) -> bool:
	assert(false, "TODO: implement this")
	# TODO: load ECS world
	# TODO: load objectives
	return true
