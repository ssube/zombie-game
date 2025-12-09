class_name SaveManager


static func create_path() -> bool:
	var user_dir := DirAccess.open("user://")
	if not user_dir.dir_exists("saves"):
		user_dir.make_dir("saves")

	return true


static func list_saves() -> Array[String]:
	SaveManager.create_path()
	var save_dir: DirAccess = DirAccess.open("user://saves")
	var save_names: Dictionary[String, bool] = {}

	save_dir.list_dir_begin()
	var file_name = save_dir.get_next()
	while file_name != "":
		if save_dir.current_is_dir():
			printerr("Nested save folders are not supported!")
		else:
			print("Found save: ", file_name)
			var clean_name = file_name.replace("_entities.tres", "").replace("_objectives.tres", "").replace(".tres", "")
			save_names[clean_name] = true

		file_name = save_dir.get_next()

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
