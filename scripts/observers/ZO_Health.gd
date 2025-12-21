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
	entity.emit_action(Enums.ActionEvent.ENTITY_DAMAGE, null)

	if c_health.hurt_sound:
		var sound_node = c_health.hurt_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound_node)

	if EntityUtils.is_objective(entity):
		var objective: ZC_Objective = entity.get_component(ZC_Objective)
		if objective.is_active and objective.complete_on_damage:
			objective.is_complete = true



func _on_death(entity: ZE_Base, c_health: ZC_Health) -> void:
	entity.emit_action(Enums.ActionEvent.ENTITY_DEATH, null)

	if c_health.death_sound:
		var sound_node = c_health.death_sound.instantiate() as ZN_AudioSubtitle3D
		entity.add_child(sound_node)

	if EntityUtils.is_objective(entity):
		var objective: ZC_Objective = entity.get_component(ZC_Objective)
		if objective.is_active and objective.complete_on_death:
			objective.is_complete = true

	if EntityUtils.is_explosive(entity):
		var explosive: ZC_Explosive = entity.get_component(ZC_Explosive)
		if explosive.explode_on_death:
			var explosion = explosive.explosion_scene.instantiate() as Node3D
			var entity_node: Node3D = entity.get_node(".") as Node3D

			# Place the explosion at the same position as the entity
			var root = entity.get_parent()
			root.add_child(explosion)
			explosion.global_transform = entity_node.global_transform

			# Remove the exploded entity
			print("Entity has exploded: ", entity)
			EntityUtils.keep_sounds(entity)
			EntityUtils.remove(entity)
