extends ZM_BaseMenu


@export var command_input: LineEdit
@export var command_history: RichTextLabel


signal command_submitted(command: String)


var _history: Array[String] = []


func _run_command_give(target_id: String, item_path: String, quantity: int = 1):
		_history.append("Giving %d of %s to %s..." % [quantity, item_path, target_id])

		var target := ECS.world.get_entity_by_id(target_id)
		if target == null:
			_history.append("Target entity %s not found!" % [target_id])
			return

		var inventory := target.get_component(ZC_Inventory) as ZC_Inventory
		if inventory == null:
			_history.append("Target entity %s has no inventory!" % [target_id])
			return

		var inventory_node := EntityUtils.get_inventory_node(target)
		if inventory_node == null:
			_history.append("Target entity %s has no inventory node!" % [target_id])
			return

		var item_resource := ResourceLoader.load(item_path) as PackedScene
		if item_resource == null:
			_history.append("Item resource %s could not be loaded!" % [item_path])
			return

		for i in range(quantity):
			var item := item_resource.instantiate() as Entity
			inventory_node.add_item(item)

		_history.append("Gave items successfully.")


func _run_command_load(level: String, spawn: String = "Markers/Start"):
	_history.append("Loading level %s at spawn %s..." % [level, spawn])
	var game := TreeUtils.get_game(self)
	game.load_level(level, spawn)


func _run_command_menu(menu_index: int):
	_history.append("Opening menu %d..." % [menu_index])
	var menu := TreeUtils.get_menu(self)
	menu.show_menu(menu_index)


func _run_command_spawn(_entity_path: String):
	assert(false, "TODO: Implement spawn command using player's current position.")


func _run_command(text: String) -> void:
	var words := text.split(" ")
	if words.size() == 0:
		return

	var keyword = words[0]
	match keyword:
		"give":
			var target_id := words[1]
			var item_path := words[2]
			var quantity := 1
			if words.size() > 3:
				quantity = int(words[3])

			_run_command_give(target_id, item_path, quantity)
		"help":
			_history.append("Available commands:")
			_history.append(" give <target_id> <item_path> [quantity]")
			_history.append(" load <level_name> [spawn_point]")
			_history.append(" menu <menu_index>")
			_history.append(" spawn <entity_path>")
		"load":
			var level := words[1]
			var spawn := "Markers/Start"
			if words.size() > 2:
				spawn = words[2]

			_run_command_load(level, spawn)
		"menu":
			var menu_index := int(words[1])
			_run_command_menu(menu_index)
		"spawn":
			var entity_path := words[1]
			_run_command_spawn(entity_path)


func _on_console_input_text_submitted(text: String) -> void:
	command_submitted.emit(text)
	_run_command(text)

	_history.append(text)
	command_input.text = ""
	on_update()


func on_show() -> void:
	super.on_show()
	command_input.grab_focus()


func on_update() -> void:
	var history := "\n".join(_history)
	command_history.text = history


func _on_run_button_pressed() -> void:
	var text := command_input.text
	_on_console_input_text_submitted(text)
