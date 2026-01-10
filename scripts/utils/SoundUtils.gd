extends Object
class_name SoundUtils

## Broadcast a sound event to all entities that can hear it
## Handles both player subtitles and zombie attention stimuli
static func broadcast(
	position: Vector3,
	radius: float,
	volume: float = 1.0,
	subtitle: String = "",
	faction: StringName = &"object",
	source_entity: Entity = null
) -> void:
	if OptionsManager.options.audio.audio_enabled == false:
		return  # Audio is disabled

	var radius_squared := radius * radius

	# Broadcast to players (subtitles)
	if subtitle != "":
		var players := EntityUtils.get_players()
		for player in players:
			var player3d := player.get_node(".") as Node3D
			var dist_sq := player3d.global_position.distance_squared_to(position)
			if dist_sq < radius_squared:
				var noise := ZC_Noise.new()
				noise.subtitle_tag = subtitle
				noise.sound_position = position
				noise.sound_volume = _calculate_intensity(dist_sq, radius_squared, volume)
				player.add_relationship(RelationshipUtils.make_heard(noise))

	# Skip stimulus broadcast if the no aggro cheat is enabled
	if OptionsManager.options.cheats.no_aggro:
		return

	# Broadcast to entities with perception (attention)
	for entity in ECS.world.query.with_all([ZC_Perception]).execute():
		if EntityUtils.is_player(entity):
			continue  # Skip players, they got subtitles

		var entity3d := entity.get_node(".") as Node3D
		var dist_sq := entity3d.global_position.distance_squared_to(position)
		if dist_sq >= radius_squared:
			continue

		var intensity := _calculate_intensity(dist_sq, radius_squared, volume)
		var stimulus := ZC_Stimulus.heard_sound(position, intensity, faction, source_entity)
		entity.add_relationship(RelationshipUtils.make_detected(stimulus))


## Calculate intensity falloff based on distance
## Returns 0.0-1.0, with 1.0 at center and 0.0 at radius edge
static func _calculate_intensity(dist_squared: float, radius_squared: float, volume: float) -> float:
	# Linear falloff, scaled by volume
	var distance_ratio := dist_squared / radius_squared
	return clampf((1.0 - distance_ratio) * volume, 0.0, 1.0)


## Convenience for common sound types
static func broadcast_gunshot(position: Vector3, source: Entity = null) -> void:
	broadcast(position, 50.0, 1.0, "gunshot", Constants.FACTION_PLAYERS, source)


static func broadcast_explosion(position: Vector3, source: Entity = null) -> void:
	broadcast(position, 80.0, 1.0, "explosion", Constants.FACTION_OBJECTS, source)


static func broadcast_footstep(position: Vector3, volume: float = 0.3, source: Entity = null) -> void:
	broadcast(position, 10.0, volume, "", Constants.FACTION_PLAYERS, source)  # No subtitle for footsteps


static func broadcast_distraction(position: Vector3, radius: float = 20.0) -> void:
	# Thrown rocks, broken glass, etc. - no source entity, draws attention to position
	broadcast(position, radius, 0.5, "", Constants.FACTION_OBJECTS, null)
