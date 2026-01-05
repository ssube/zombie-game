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

	# TODO: sync to the component's item_ids

	return _item_cache


func _get_holder_inventory() -> ZC_Inventory:
	assert(parent_entity != null, "Holder entity is not set for inventory node.")
	var inventory := parent_entity.get_component(ZC_Inventory) as ZC_Inventory
	assert(inventory != null, "Holder entity does not have an inventory component.")
	return inventory


func _ready() -> void:
	_cache_items()


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