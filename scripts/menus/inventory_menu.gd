extends ZM_BaseMenu


@export var inventory_list: ItemList

## Items held by player, not including keys which cannot be used
var _item_players: Dictionary[Entity, Entity] = {}
var _item_index: Dictionary[int, Entity] = {}


signal item_activated(player: Entity, item: Entity, index: int)


func on_update() -> void:
	_item_index.clear()
	_item_players.clear()

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
				_item_players[player.current_weapon] = player

		if "inventory_node" in player:
			var player_inventory = player.inventory_node.get_children()
			for item in player_inventory:
				if item is Entity:
					inventory.append(item)
					_item_players[item] = player

	inventory_list.clear()
	if inventory.size() == 0:
		inventory_list.add_item("No Items", null, false)
	else:
		for item in inventory:
			var interactive := item.get_component(ZC_Interactive) as ZC_Interactive
			var index := inventory_list.add_item(interactive.name)
			_item_index[index] = item

	if keys.size() == 0:
		inventory_list.add_item("No Keys", null, false)
	else:
		for key in keys:
			inventory_list.add_item("Key: " + key, null, false)


func _on_inventory_list_item_activated(index: int) -> void:
	var list := $MarginContainer/VFlowContainer/InventoryList as ItemList
	if not list.is_item_selectable(index):
		return

	var item := _item_index.get(index) as Entity
	if item == null:
		return

	var player = _item_players.get(item) as Entity
	player.add_relationship(RelationshipUtils.make_used(item))
	item_activated.emit(player, item, index)


func _on_back_pressed() -> void:
	back_pressed.emit()
