extends ZM_BaseMenu


@export var inventory_list: ItemList


func on_update() -> void:
	var players: Array[Entity] = ECS.world.query.with_all([ZC_Player]).execute()
	var inventory: Array[Entity] = []
	var keys: Array[String] = []
	for player in players:
		var c_player := player.get_component(ZC_Player) as ZC_Player
		keys.append_array(c_player.held_keys)

		if "current_weapon" in player:
			var player_weapon = player.current_weapon as Node
			if player_weapon != null and player_weapon is Entity:
				inventory.append(player_weapon)

		if "inventory_node" in player:
			var player_inventory = player.inventory_node.get_children()
			for item in player_inventory:
				if item is Entity:
					inventory.append(item)

	inventory_list.clear()
	if inventory.size() == 0:
		inventory_list.add_item("No Items", null, false)
	else:
		for item in inventory:
			var interactive := item.get_component(ZC_Interactive) as ZC_Interactive
			inventory_list.add_item(interactive.name)

	if keys.size() == 0:
		inventory_list.add_item("No Keys", null, false)
	else:
		for key in keys:
			inventory_list.add_item("Key: " + key, null, false)


func _on_inventory_list_item_activated(index: int) -> void:
	var list := $MenuLayer/InventoryMenu/MarginContainer/VFlowContainer/InventoryList as ItemList
	if list.is_item_selectable(index):
		var item := list.get_item_text(index)
		printerr("TODO: use inventory item: ", item)
		# TODO: get player that is holding item and call ZS_Player.use_item
		# var player := RelationshipUtils.get_holder(


func _on_back_pressed() -> void:
	back_pressed.emit()
