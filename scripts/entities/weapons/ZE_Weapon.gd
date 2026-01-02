@tool
extends ZE_Equipment
class_name ZE_Weapon


var _effects_cache: Dictionary[ZR_Weapon_Effect.EffectType, Array] = {}


func _get_effects() -> Array[ZR_Weapon_Effect]:
	var effects: Array[ZR_Weapon_Effect] = []

	if self.has_component(ZC_Weapon_Melee):
		var melee := self.get_component(ZC_Weapon_Melee) as ZC_Weapon_Melee
		effects.append_array(melee.effects)

	if self.has_component(ZC_Weapon_Ranged):
		var ranged := self.get_component(ZC_Weapon_Ranged) as ZC_Weapon_Ranged
		effects.append_array(ranged.effects)

	if self.has_component(ZC_Weapon_Thrown):
		var thrown := self.get_component(ZC_Weapon_Thrown) as ZC_Weapon_Thrown
		effects.append_array(thrown.effects)

	return effects


func on_ready() -> void:
	super.on_ready()

	var cached := 0
	var effects := _get_effects()
	for effect_name in ZR_Weapon_Effect.EffectType:
		var effect_type := ZR_Weapon_Effect.EffectType[effect_name] as ZR_Weapon_Effect.EffectType
		var cache_for_type := _effects_cache.get(effect_type, []) as Array
		for effect in effects:
			if effect.effect_type == effect_type:
				cache_for_type.append(effect)
				cached += 1

		if cache_for_type.size() > 0:
			_effects_cache[effect_type] = cache_for_type

	print("Cached %d effects for weapon %s" % [cached, self.id])

func apply_effects(effect_type: ZR_Weapon_Effect.EffectType) -> Array[Node3D]:
	var use_projectile = false
	match effect_type:
		ZR_Weapon_Effect.EffectType.RANGED_FIRE:
			use_projectile = true
		ZR_Weapon_Effect.EffectType.RANGED_RECOIL:
			use_projectile = OptionsManager.options.gameplay.physical_casings
		ZR_Weapon_Effect.EffectType.RANGED_RELOAD:
			use_projectile = OptionsManager.options.gameplay.physical_mags

	var effects := _effects_cache.get(effect_type, []) as Array
	var effect_scenes: Array[Node3D] = []
	for effect: ZR_Weapon_Effect in effects:
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
