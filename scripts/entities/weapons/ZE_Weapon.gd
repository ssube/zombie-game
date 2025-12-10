@tool
extends ZE_Base
class_name ZE_Weapon

# TODO: move to game settings
var physical_shells: bool = true
var physical_mags: bool = true

func apply_effects(effect_type: ZR_Weapon_Effect.EffectType) -> Array[Node3D]:
	var effects: Array[ZR_Weapon_Effect] = []

	if self.has_component(ZC_Weapon_Ranged):
		var ranged := self.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
		effects.append_array(ranged.effects)

	if self.has_component(ZC_Weapon_Melee):
		var melee := self.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
		effects.append_array(melee.effects)

	var use_projectile = false
	match effect_type:
		ZR_Weapon_Effect.EffectType.MUZZLE_FIRE:
			use_projectile = true
		ZR_Weapon_Effect.EffectType.RECOIL:
			use_projectile = physical_shells
		ZR_Weapon_Effect.EffectType.RELOAD:
			use_projectile = physical_mags

	var effect_scenes: Array[Node3D] = []
	for effect in effects:
		if effect.effect_type == effect_type:
			var effect_marker := self.get_node(effect.marker)

			if effect.effect_scene:
				var effect_scene := effect.effect_scene.instantiate()
				effect_marker.add_child(effect_scene)
				effect_scenes.append(effect_scene)

			if use_projectile and effect.projectile_scene:
				var projectile_scene := effect.projectile_scene.instantiate()
				effect_marker.add_child(projectile_scene)
				effect_scenes.append(projectile_scene)

	return effect_scenes
