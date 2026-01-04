@tool
extends ZE_Character
class_name ZE_Player

@export var hands_node: Node3D = null

## Tracks the last entity this player looked at for shimmer effect management
var last_shimmer_target: Entity = null

func on_ready():
	super.on_ready()
	sync_experience()
	sync_health()
	sync_stamina()


func sync_experience():
	var c_experience := get_component(ZC_Experience) as ZC_Experience
	if not c_experience:
		return

	%Menu.set_score(c_experience.total_xp)


## Sync health from component to menu
func sync_health():
	var c_health := get_component(ZC_Health) as ZC_Health
	if not c_health:
		return

	%Menu.set_health(c_health.current_health, true)


func sync_stamina():
	var c_stamina := get_component(ZC_Stamina) as ZC_Stamina
	if not c_stamina:
		return

	%Menu.set_stamina(c_stamina.current_stamina, true)


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
				ZombieLogger.debug("Equipped weapon: {0}", [current_weapon])
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
