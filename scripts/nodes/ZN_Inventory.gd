extends Node3D
class_name ZN_Inventory


@export var parent_entity: Entity


var _item_cache: Array[Entity] = []
# var _items_by_id: Dictionary[String, Entity] = {}
# var _items_by_name: Dictionary[String, Entity] = {}


var items: Array[Entity]:
	get():
		return _item_cache.duplicate()


func _cache_items() -> Array[Entity]:
	_item_cache.clear()
	var children := get_children()
	for child in children:
		if child is Entity:
			_item_cache.append(child)

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
	return items.size()


func add_item(item: Entity) -> bool:
	var component := _get_holder_inventory()
	if component.max_slots > 0 and items.size() >= component.max_slots:
		return false

	add_child(item)
	_item_cache.append(item)
	component.item_ids[item.id] = true
	return true


func remove_item(item: Entity) -> void:
	if item in items:
		self.remove_child(item)
		_item_cache.erase(item)
		var component := _get_holder_inventory()
		component.item_ids.erase(item.id)
