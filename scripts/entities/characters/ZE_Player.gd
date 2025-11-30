@tool
extends ZE_Base
class_name ZE_Player

@export var current_weapon: ZE_Weapon = null
@export var inventory_node: Node = null
@export var hands_node: Node3D = null

func on_ready():
	sync_health()
	sync_transform()


## Sync health from component to menu
func sync_health():
	var c_health = get_component(ZC_Health) as ZC_Health
	if not c_health:
		return

	%Hud.set_health(c_health.current_health, true)


## Sync transform from scene to component
func sync_transform():
	var c_trs = get_component(ZC_Transform) as ZC_Transform
	if not c_trs:
		return

	var root := self.get_node(".") as Node3D
	c_trs.position = root.global_position
	c_trs.rotation = root.global_rotation


func get_inventory() -> Array[Entity]:
	var items: Array[Entity] = []
	if inventory_node == null:
		return items

	for child in inventory_node.get_children():
		if child is Entity:
			items.append(child as Entity)

	return items


func equip_weapon(weapon_name: String) -> bool:
	var entity_inventory = get_inventory()
	for entity in entity_inventory:
		if entity.has_component(ZC_Interactive):
			var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
			if interactive.name == weapon_name:
				current_weapon = entity as ZE_Weapon
				print("Equipped weapon: ", current_weapon)
				return true

	return false


func has_weapon(weapon_name: String) -> bool:
	var entity_inventory = get_inventory()
	for entity in entity_inventory:
		if entity.has_component(ZC_Interactive):
			var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
			if interactive.name == weapon_name:
				return true

	return false
