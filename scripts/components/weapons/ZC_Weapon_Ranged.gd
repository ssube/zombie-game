extends ZC_Weapon_Base
class_name ZC_Weapon_Ranged

@export_group("Muzzle")
@export var muzzle_velocity: float = 30.0
@export var muzzle_marker: NodePath

@export_group("Cooldown")
@export_subgroup("Recoil")
@export var recoil_per_shot: float = 1.0
@export var recoil_time: float = 0.25
@export var recoil_marker: NodePath
@export var recoil_path: NodePath

@export_subgroup("Reload")
@export var reload_time: float = 5.0
@export var reload_marker: NodePath
@export var reload_path: NodePath

@export_group("Ammo")
@export var ammo_type: String
@export var per_shot: int = 1
@export var per_reload: int = 10

@export_group("Projectile")
# TODO: remove in favor of the RANGED_FIRE weapon effect's projectile scene
@export var projectile_scene: PackedScene = null
