extends Observer
class_name ZO_HealthObserver

func watch() -> Resource:
	return ZC_Health


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	if new_value == old_value:
		printerr("Health triggered fake change: ", entity, new_value)
		return

	var c_health := component as ZC_Health
	if new_value == 0:
		_on_death(entity, c_health)
	elif new_value > 0 and new_value < old_value:
		_on_damage(entity, c_health)

	call_deferred("_update_skin", entity, c_health, new_value)

	if EntityUtils.is_player(entity):
		print("Health changed: ", property, " from ", old_value, " to ", new_value)
		if new_value != old_value:
			call_deferred("_update_hud", new_value)


func _update_skin(entity: Entity, c_health: ZC_Health, new_value: int) -> void:
	var skin := entity.get_component(ZC_Skin) as ZC_Skin
	if skin != null:
		if new_value <= 0:
			skin.current_skin = ZC_Skin.SkinType.DEAD
		elif new_value < c_health.max_health:
			skin.current_skin = ZC_Skin.SkinType.HURT
		elif new_value == c_health.max_health:
			skin.current_skin = ZC_Skin.SkinType.HEALTHY


func _update_hud(health: int) -> void:
	%Menu.set_health(health)


func _on_damage(entity: ZE_Base, c_health: ZC_Health) -> void:
	var hitter := entity.get_relationship(RelationshipUtils.any_hit)
	entity.emit_action(Enums.ActionEvent.ENTITY_DAMAGE, hitter.target)

	if c_health.hurt_sound:
		var sound_node = c_health.hurt_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound_node)

	if EntityUtils.is_objective(entity):
		var objective: ZC_Objective = entity.get_component(ZC_Objective)
		if objective.is_active and objective.complete_on_damage:
			objective.is_complete = true


func _on_death(entity: ZE_Base, c_health: ZC_Health) -> void:
	var killer := RelationshipUtils.get_killer(entity)
	entity.emit_action(Enums.ActionEvent.ENTITY_DEATH, killer)

	if c_health.death_sound:
		var sound_node = c_health.death_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound_node)

	if EntityUtils.is_objective(entity):
		var objective: ZC_Objective = entity.get_component(ZC_Objective)
		if objective.is_active and objective.complete_on_death:
			objective.is_complete = true
