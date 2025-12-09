extends Observer
class_name ZO_AudioObserver

func watch() -> Resource:
	return ZC_Noise

func on_component_added(entity: Entity, _component: Resource) -> void:
	var noise = entity.get_component(ZC_Noise) as ZC_Noise
	var audio_node = entity.get_node(noise.audio_node) as ZN_AudioSubtitle3D
	if audio_node == null:
		return

	var players = ECS.world.query.with_all([ZC_Player]).execute()
	for player: Node3D in players:
		if player.global_position.distance_squared_to(audio_node.global_position) < audio_node.radius_squared:
			%Menu.push_action(audio_node.subtitle_tag)

	audio_node.play_subtitle()
	entity.remove_component(noise)
