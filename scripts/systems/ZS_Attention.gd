extends System
class_name ZS_AttentionSystem

func query() -> QueryBuilder:
	return q.with_all([ZC_Perception, ZC_Attention])

func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var perception := entity.get_component(ZC_Perception) as ZC_Perception
		var attention := entity.get_component(ZC_Attention) as ZC_Attention

		attention.previous_score = attention.score

		# Process stimuli buffer
		var stimuli := entity.get_relationships(RelationshipUtils.any_detected) as Array[Relationship]
		var dominated := false  # Track if any stimulus "won" this frame
		for rel in stimuli:
			var stimulus := rel.target as ZC_Stimulus
			dominated = _process_stimulus(attention, stimulus) or dominated
		entity.remove_relationships(stimuli)

		# Apply decay
		if not dominated:
			attention.time_since_stimulus += delta
			# lerp toward 0
			attention.score = lerpf(attention.score, 0.0, attention.decay_rate * delta)
		else:
			attention.time_since_stimulus = 0.0

		# Update visible entities for line-of-sight checks
		_update_visible_target(attention, perception)

func _process_stimulus(attention: ZC_Attention, stimulus: ZC_Stimulus) -> bool:
	# Calculate stimulus score
	var faction_score: float = attention.faction_scores.get(stimulus.faction, 0.1)
	var type_multiplier: float = attention.type_multipliers.get(stimulus.type, 1.0)
	var stimulus_score: float = clampf(faction_score * type_multiplier * stimulus.intensity, 0.0, 2.0)

	# If stimulus is stronger, we move toward it; if weaker, we stay near current
	var integration_rate := 0.5  # How quickly we respond to new stimuli
	var new_score := lerpf(attention.score, stimulus_score, integration_rate)

	# Only update target if this stimulus "wins" (higher than current)
	if stimulus_score > attention.score or stimulus_score > attention.previous_score + attention.score_change_threshold:
		attention.target_entity = stimulus.source_entity  # May be null for sounds
		attention.target_position = stimulus.position
		attention.score = maxf(attention.score, new_score)
		return true

	return false

func _update_visible_target(attention: ZC_Attention, perception: ZC_Perception) -> void:
	# If we have a target entity, check if still visible
	if attention.target_entity != "":
		# If not visible, we keep the last known position (memory)
		if attention.target_entity in perception.visible_entities:
			# Update position to current (we can see them)
			var entity := ECS.world.get_entity_by_id(attention.target_entity)
			attention.target_position = entity.global_position
