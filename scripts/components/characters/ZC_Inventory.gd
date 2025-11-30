extends Component
class_name ZC_Inventory

@export var keys: Array[String] = []
@export var weapons: Array[ZC_Weapon_Base] = []
@export var equipped_weapon: ZC_Weapon_Base = null

#region Key Management
func add_key(key_name: String) -> void:
	if not has_key(key_name):
		keys.append(key_name)

func has_key(key_name: String) -> bool:
	return key_name in keys
#endregion

#region Weapon Management
func add_weapon(weapon: ZC_Weapon_Base) -> void:
	weapons.append(weapon)

func remove_weapon(weapon: ZC_Weapon_Base) -> void:
	var removed: Array[ZC_Weapon_Base] = []
	for check_weapon in weapons:
		if check_weapon.name == weapon.name:
			removed.append(check_weapon)

	for rem_weapon in removed:
		weapons.erase(rem_weapon)

func has_weapon(weapon_name: String) -> bool:
	var weapon = find_weapon(weapon_name)
	return weapon != null

func equip_weapon(weapon_name: String) -> bool:
	var weapon = find_weapon(weapon_name)
	if weapon == null:
		return false

	equipped_weapon = weapon
	print("Equipped weapon: ", equipped_weapon.name)
	return true

func find_weapon(weapon_name: String) -> ZC_Weapon_Base:
	for check_weapon in weapons:
		if check_weapon.name == weapon_name:
			return check_weapon

	return null

func unequip_weapon() -> void:
	equipped_weapon = null

#region Weapon Scrolling
func next_weapon() -> void:
	if weapons.size() == 0:
		equipped_weapon = null
		return

	if equipped_weapon == null:
		equipped_weapon = weapons[0]
		return

	var current_index = weapons.find(equipped_weapon)
	var next_index = (current_index + 1) % weapons.size()
	var weapon = weapons[next_index]
	equip_weapon(weapon.name)
	print("Equipped weapon: ", weapon.name)

func previous_weapon() -> void:
	if weapons.size() == 0:
		equipped_weapon = null
		return

	if equipped_weapon == null:
		equipped_weapon = weapons[weapons.size() - 1]
		return

	var current_index = weapons.find(equipped_weapon)
	var previous_index = (current_index - 1 + weapons.size()) % weapons.size()
	var weapon = weapons[previous_index]
	equip_weapon(weapon.name)
	print("Equipped weapon: ", weapon.name)
#endregion
#endregion
