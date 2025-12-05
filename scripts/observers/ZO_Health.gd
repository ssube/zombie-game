extends Observer
class_name ZO_HealthObserver

func watch() -> Resource:
	return ZC_Health

#func match():
#	return q.with_all([ZC_Health, ZC_Player])

func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	if new_value == old_value:
		printerr("Health triggered fake change: ", entity, new_value)
		return

	var c_health := component as ZC_Health
	if new_value == 0 and c_health.death_sound:
		var sound_node = entity.get_node(c_health.death_sound) as ZN_AudioSubtitle3D
		if sound_node != null:
			var c_noise := ZC_Noise.from_node(sound_node)
			entity.add_component(c_noise)

	if new_value > 0 and c_health.hurt_sound:
		var sound_node = entity.get_node(c_health.hurt_sound) as ZN_AudioSubtitle3D
		if sound_node != null:
			var c_noise := ZC_Noise.from_node(sound_node)
			entity.add_component(c_noise)

	if EntityUtils.is_player(entity):
		print("Health changed: ", property, " from ", old_value, " to ", new_value)
		if new_value != old_value:
			call_deferred("update_hud", new_value)

func update_hud(health: int) -> void:
	%Hud.set_health(health)
