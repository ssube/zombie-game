extends Resource
class_name ZR_Weapon_Effect

enum EffectType { CODE_ONLY, MELEE_SWING, MUZZLE_FIRE, RECOIL, RELOAD }

@export var effect_type: EffectType = EffectType.CODE_ONLY
@export var marker: NodePath
@export var effect_scene: PackedScene

## TODO: can be removed in favor of the projectile for the MUZZLE_FIRE event
@export var projectile_scene: PackedScene

## TODO: unused
# @export var velocity: Vector3 = Vector3.FORWARD
