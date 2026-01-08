extends ZM_BaseMenu


@export var inventory_list: ItemList
@export var use_button: Button
@export var equip_button: Button
@export var unequip_button: Button
@export var drop_button: Button


## Items held by player, not including keys which cannot be used
var _item_players: Dictionary[Entity, Entity] = {}
var _item_index: Dictionary[int, Entity] = {}


signal item_activated(player: Entity, item: Entity, index: int)


func on_update() -> void:
	_item_index.clear()
	_item_players.clear()
	_show_action_buttons()

	var players: Array[Entity] = EntityUtils.get_players()
	var inventory: Array[Entity] = []
	var keys: Array[String] = []
	var ammo: Dictionary[String, int] = {}

	for player in players:
		var c_player := player.get_component(ZC_Player) as ZC_Player
		keys.append_array(c_player.held_keys)

		var player_ammo := player.get_component(ZC_Ammo) as ZC_Ammo
		if player_ammo:
			for ammo_type in player_ammo.ammo_count.keys():
				ammo[ammo_type] = player_ammo.get_ammo(ammo_type) + ammo.get(ammo_type, 0)

		var player_inventory := RelationshipUtils.get_inventory(player)
		for item in player_inventory:
			if item != null:
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

	if ammo.size() == 0:
		inventory_list.add_item("No Ammo", null, false)
	else:
		for ammo_type in ammo:
			var ammo_text = "Ammo: %d of %s" % [ammo[ammo_type], ammo_type]
			inventory_list.add_item(ammo_text, null, false)


# TODO: find a better way to do this, split up the handlers
func _on_inventory_list_item_activated(index: int) -> void:
	if not inventory_list.is_item_selectable(index):
		return

	var item := _item_index.get(index) as Entity
	if item == null:
		return

	var player = _item_players.get(item) as Entity
	var equipment := item.get_component(ZC_Equipment) as ZC_Equipment
	if equipment and equipment.equippable:
		var equipped := false
		if EntityUtils.is_weapon(item):
			EntityUtils.equip_weapon(player, item as ZE_Weapon)
			# TODO: assume it succeeds for now
			equipped = true
		else:
			equipped = EntityUtils.equip_item(player, item)

		if not equipped:
			ZombieLogger.error("Unable to equip {0}!", [item.name])
	else:
		player.add_relationship(RelationshipUtils.make_used(item))

	item_activated.emit(player, item, index)


func _on_back_pressed() -> void:
	back_pressed.emit()


func _on_use_button_pressed() -> void:
	_activate_selected_items()


func _on_equip_button_pressed() -> void:
	_activate_selected_items()


func _on_unequip_button_pressed() -> void:
	var selected := inventory_list.get_selected_items()
	for index in selected:
		if not inventory_list.is_item_selectable(index):
			return

		var item := _item_index.get(index) as Entity
		if item == null:
			return

		var player = _item_players.get(item) as Entity
		EntityUtils.unequip_item(player, item)


func _on_drop_button_pressed() -> void:
	var selected := inventory_list.get_selected_items()
	for index in selected:
		if not inventory_list.is_item_selectable(index):
			return

		var item := _item_index.get(index) as Entity
		if item == null:
			return

		var player = _item_players.get(item) as Entity
		EntityUtils.drop_item(player, item)


func _activate_selected_items() -> void:
	var selected := inventory_list.get_selected_items()
	for index in selected:
		_on_inventory_list_item_activated(index)


func _show_action_buttons() -> void:
	var show_use := false
	var show_equip := false
	var show_unequip := false
	var show_drop := false

	var selected := inventory_list.get_selected_items()
	for index in selected:
		var item := _item_index.get(index) as Entity
		if item == null:
			return

		var equipment := item.get_component(ZC_Equipment) as ZC_Equipment
		if equipment != null:
			var player := _item_players.get(item) as Entity
			var is_equipped := player.has_relationship(RelationshipUtils.make_equipped(item))
			show_equip = show_equip or not is_equipped # equipment.slot.is_empty()
			show_unequip = show_unequip or is_equipped # not equipment.slot.is_empty()
			show_drop = show_drop or equipment.droppable

		if item.has_component(ZC_Food):
			show_use = true

	use_button.disabled = not show_use
	equip_button.disabled = not show_equip
	unequip_button.disabled = not show_unequip
	drop_button.disabled = not show_drop


func _on_inventory_list_item_selected(_index: int) -> void:
	_show_action_buttons()
