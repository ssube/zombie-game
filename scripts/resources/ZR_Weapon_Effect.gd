extends Resource
class_name ZR_Weapon_Effect

enum EffectType { CODE_ONLY, MELEE_SWING, RANGED_FIRE, RANGED_RECOIL, RANGED_RELOAD, MELEE_BREAK, MELEE_REPAIR, RANGED_EMPTY }

@export var effect_type: EffectType = EffectType.CODE_ONLY
@export var marker: NodePath
@export var effect_scene: PackedScene
@export var projectile_scene: PackedScene

## TODO: unused
# @export var velocity: Vector3 = Vector3.FORWARD
