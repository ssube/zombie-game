extends Node3D
class_name ZN_Inventory


@export var parent_entity: Entity


var _item_cache: Array[Entity] = []

#region Indexes
var _items_by_id: Dictionary[String, Entity] = {}
var _items_by_name: Dictionary[String, Entity] = {}
var _items_by_shortcut: Dictionary[ZC_ItemShortcut.ItemShortcut, Entity] = {}
#endregion


var items: Array[Entity]:
	get():
		return _item_cache.duplicate()


func _index_item(item: Entity) -> void:
	_items_by_id[item.id] = item

	var interactive := item.get_component(ZC_Interactive) as ZC_Interactive
	if interactive != null:
		_items_by_name[interactive.name] = item

	# TODO: support stacks for each shortcut
	var shortcut := item.get_component(ZC_ItemShortcut) as ZC_ItemShortcut
	if shortcut != null:
		_items_by_shortcut[shortcut.shortcut] = item


func _deindex_item(item: Entity) -> void:
	_items_by_id.erase(item.id)

	var interactive := item.get_component(ZC_Interactive) as ZC_Interactive
	if interactive != null:
		_items_by_name.erase(interactive.name)

	var shortcut := item.get_component(ZC_ItemShortcut) as ZC_ItemShortcut
	if shortcut != null:
		_items_by_shortcut.erase(shortcut.shortcut)


func _cache_items() -> Array[Entity]:
	_item_cache.clear()
	_items_by_id.clear()
	_items_by_name.clear()
	_items_by_shortcut.clear()

	var children := get_children()
	for child in children:
		if child is Entity:
			_item_cache.append(child)
			_index_item(child as Entity)

	# sync to the component
	# the ECS world may not be fully initialized yet, so the component may not exist
	if parent_entity.has_component(ZC_Inventory):
		var component := parent_entity.get_component(ZC_Inventory) as ZC_Inventory
		component.item_ids.clear()
		for item in _item_cache:
			component.item_ids[item.id] = true

	return _item_cache


func _on_direct_add(_item: Entity) -> void:
	# TODO: drop item if inventory full
	# TODO: update this item, not the whole cache
	_cache_items()


func _on_direct_remove(_item: Entity) -> void:
	# TODO: update this item, not the whole cache
	_cache_items()


func _get_holder_inventory() -> ZC_Inventory:
	assert(parent_entity != null, "Holder entity is not set for inventory node.")
	var inventory := parent_entity.get_component(ZC_Inventory) as ZC_Inventory
	assert(inventory != null, "Holder entity does not have an inventory component.")
	return inventory


func _ready() -> void:
	# TODO: make sure any initial children get a Holding relationship added to the parent entity
	_cache_items()

	# bind to child_entered_tree and child_exiting_tree signals to keep cache updated
	child_entered_tree.connect(_on_direct_add)
	child_exiting_tree.connect(_on_direct_remove)


func size() -> int:
	return _item_cache.size()


func add_item(item: Entity) -> bool:
	var component := _get_holder_inventory()
	if component == null:
		return false

	if not component.allow_add_items:
		return false

	if component.max_slots > 0 and _item_cache.size() >= component.max_slots:
		return false

	add_child(item)
	_item_cache.append(item)
	_index_item(item)
	component.item_ids[item.id] = true
	return true


func remove_item(item: Entity) -> void:
	var component := _get_holder_inventory()
	if component == null:
		return

	if not component.allow_remove_items:
		return

	if item in _item_cache:
		self.remove_child(item)
		_item_cache.erase(item)
		_deindex_item(item)
		component.item_ids.erase(item.id)


func get_by_id(id: String) -> Entity:
	return _items_by_id.get(id, null)


func get_by_name(item_name: String) -> Entity:
	return _items_by_name.get(item_name, null)


func get_by_shortcut(shortcut: ZC_ItemShortcut.ItemShortcut) -> Entity:
	return _items_by_shortcut.get(shortcut, null)
