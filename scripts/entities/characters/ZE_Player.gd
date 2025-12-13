@tool
extends ZE_Character
class_name ZE_Player

@export var hands_node: Node3D = null

func on_ready():
	sync_health()


## Sync health from component to menu
func sync_health():
	var c_health = get_component(ZC_Health) as ZC_Health
	if not c_health:
		return

	%Menu.set_health(c_health.current_health, true)


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
		if EntityUtils.is_interactive(entity):
			var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
			if interactive.name == weapon_name:
				current_weapon = entity as ZE_Weapon
				print("Equipped weapon: ", current_weapon)
				return true

	return false


func has_weapon(weapon_name: String) -> bool:
	var entity_inventory = get_inventory()
	for entity in entity_inventory:
		if EntityUtils.is_interactive(entity):
			var interactive = entity.get_component(ZC_Interactive) as ZC_Interactive
			if interactive.name == weapon_name:
				return true

	return false
