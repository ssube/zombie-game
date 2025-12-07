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
@export var current_ammo : int = 10
@export var per_reload: int = 10
@export var max_ammo: int = 100

@export_group("Projectile")
@export var projectile_scene: PackedScene = null
# @export var projectile_effect: PackedScene = null
