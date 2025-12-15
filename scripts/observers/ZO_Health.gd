extends Observer
class_name ZO_HealthObserver

func watch() -> Resource:
	return ZC_Health


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	if new_value == old_value:
		printerr("Health triggered fake change: ", entity, new_value)
		return

	var c_health := component as ZC_Health
	if new_value == 0 and c_health.death_sound:
		var sound_node = c_health.death_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound_node)

	call_deferred("update_skin", entity, c_health, new_value)

	if new_value > 0 and c_health.hurt_sound:
		var sound_node = c_health.hurt_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound_node)

	if EntityUtils.is_player(entity):
		print("Health changed: ", property, " from ", old_value, " to ", new_value)
		if new_value != old_value:
			call_deferred("update_hud", new_value)


func update_skin(entity: Entity, c_health: ZC_Health, new_value: int) -> void:
	var skin := entity.get_component(ZC_Skin) as ZC_Skin
	if skin != null:
		if new_value <= 0:
			skin.current_skin = ZC_Skin.SkinType.DEAD
		elif new_value < c_health.max_health:
			skin.current_skin = ZC_Skin.SkinType.HURT
		elif new_value == c_health.max_health:
			skin.current_skin = ZC_Skin.SkinType.HEALTHY


func update_hud(health: int) -> void:
	%Menu.set_health(health)
