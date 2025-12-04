extends Component
class_name ZC_Weapon_Ranged

@export var muzzle_velocity: float = 30.0
@export var muzzle_marker: NodePath
@export var recoil_time: float = 0.25
@export var reload_time: float = 5.0
@export var current_ammo : int = 10
@export var max_ammo: int = 10
@export var projectile_scene: PackedScene = null
@export var projectile_sound: NodePath