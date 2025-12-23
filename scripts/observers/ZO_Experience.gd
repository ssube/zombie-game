extends Observer
class_name ZO_ExperienceObserver

enum LevelMode {
	LINEAR,
	EXPONENTIAL,
}

@export var level_increment: float = 1000.0
@export var level_mode: LevelMode = LevelMode.LINEAR


func watch() -> Resource:
	return ZC_Experience


func on_component_changed(entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant):
	if new_value == old_value:
		return

	var c_experience := component as ZC_Experience
	assert(c_experience != null, "Experience observer is expecting an experience component!")

	# Only recalculate level when earned_xp or base_xp changes
	if property == "earned_xp" or property == "base_xp":
		var old_level := c_experience.level
		var new_level := _calculate_level(c_experience)

		if new_level != old_level:
			# Level changed - update the level
			c_experience.level = new_level
			_on_level_up(entity, c_experience, old_level, new_level)

		if EntityUtils.is_player(entity):
			print("Experience changed for player: ", property, " from ", old_value, " to ", new_value, " (Level: ", new_level, ")")


func _calculate_level(c_experience: ZC_Experience) -> int:
	if level_increment <= 0:
		return 0

	var total_xp := c_experience.base_xp + c_experience.earned_xp

	match level_mode:
		LevelMode.LINEAR:
			# Series: 1000, 2000, 3000... (level_increment * n)
			return int(total_xp / level_increment)
		LevelMode.EXPONENTIAL:
			# Series: 1000, 4000, 9000... (level_increment * n^2)
			return int(sqrt(float(total_xp) / level_increment))
		_:
			return 0


func _on_level_up(entity: Entity, _c_experience: ZC_Experience, old_level: int, new_level: int) -> void:
	print("Entity %s leveled up from %d to %d!" % [entity.id, old_level, new_level])

	# TODO: Show level-up menu for players
	if EntityUtils.is_player(entity):
		call_deferred("_show_level_up_menu", entity, old_level, new_level)


func _show_level_up_menu(_entity: Entity, old_level: int, new_level: int) -> void:
	# TODO: Implement level-up menu
	# For now, just log to console
	print("Player leveled up! Old level: %d, New level: %d" % [old_level, new_level])
	# %Menu.show_level_up(old_level, new_level)
