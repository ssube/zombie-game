extends Resource
class_name ZR_Weapon_Effect

enum EffectType { CODE_ONLY = 0, MUZZLE_FIRE = 1, RECOIL = 2, RELOAD = 4 }

@export var effect_type: EffectType = EffectType.CODE_ONLY
@export var marker: NodePath
@export var effect_scene: PackedScene

## TODO: could contain the actual bullet for MUZZLE_FIRE
@export var projectile_scene: PackedScene

## TODO: unused
# @export var velocity: Vector3 = Vector3.FORWARD
