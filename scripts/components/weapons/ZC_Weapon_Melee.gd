extends ZC_Weapon_Base
class_name ZC_Weapon_Melee

@export var swing_path: NodePath
@export var swing_time: float = 2.0
@export var cooldown_time: float = 1.0
@export var damage_areas: Array[NodePath] = []
