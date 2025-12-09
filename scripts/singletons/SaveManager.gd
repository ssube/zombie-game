class_name SaveManager


static func create_path() -> bool:
	var user_dir := DirAccess.open("user://")
	if not user_dir.dir_exists("saves"):
		user_dir.make_dir("saves")

	return true


static func list_saves() -> Array[String]:
	assert(false, "TODO: implement this")
	SaveManager.create_path()
	return []


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
