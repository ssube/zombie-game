extends Component
class_name ZC_Stimulus

enum StimulusType {
	SAW_ENTITY,
	HEARD_SOUND,
	TOOK_DAMAGE,
	SAW_AGGRESSIVE_ALLY,
}

@export var type: StimulusType
@export var source_entity: String = ""  # May be empty for sounds
@export var position: Vector3 = Vector3.ZERO
@export var intensity: float = 1.0  # 0.0-1.0, based on distance/volume/visibility
@export var faction: StringName = &""  # Faction of source, for scoring
@export var timestamp: float = 0.0

func _init() -> void:
	timestamp = Time.get_ticks_msec()


static func heard_sound(pos: Vector3, loudness: float, source_faction: StringName, source: Entity = null) -> ZC_Stimulus:
	var stimulus := ZC_Stimulus.new()
	stimulus.type = StimulusType.HEARD_SOUND
	stimulus.position = pos
	stimulus.intensity = loudness
	stimulus.faction = source_faction
	if source:
		stimulus.source_entity = source.id
	return stimulus


static func saw_entity(seen: Entity, visual_intensity: float) -> ZC_Stimulus:
	var stimulus := ZC_Stimulus.new()
	stimulus.type = StimulusType.SAW_ENTITY
	stimulus.source_entity = seen.id
	stimulus.position = seen.global_position
	stimulus.intensity = visual_intensity
	# Get faction from seen entity
	var faction_comp := seen.get_component(ZC_Faction) as ZC_Faction
	if faction_comp:
		stimulus.faction = faction_comp.faction_name
	else:
		stimulus.faction = Constants.FACTION_OBJECTS
	return stimulus


static func took_damage(from_entity: Entity, damage_pos: Vector3) -> ZC_Stimulus:
	var stimulus := ZC_Stimulus.new()
	stimulus.type = StimulusType.TOOK_DAMAGE
	stimulus.position = damage_pos
	stimulus.intensity = 1.0  # Damage is always max intensity
	if from_entity:
		stimulus.source_entity = from_entity.id
		var faction_comp := from_entity.get_component(ZC_Faction) as ZC_Faction
		if faction_comp:
			stimulus.faction = faction_comp.faction_name
	return stimulus


static func saw_aggressive_ally(ally_target: Entity, ally_target_pos: Vector3, ally_score: float) -> ZC_Stimulus:
	var stimulus := ZC_Stimulus.new()
	stimulus.type = StimulusType.SAW_AGGRESSIVE_ALLY
	stimulus.position = ally_target_pos
	stimulus.intensity = ally_score * 0.6  # Reduced from ally's intensity
	stimulus.faction = Constants.FACTION_PLAYERS  # Assume threat
	if ally_target:
		stimulus.source_entity = ally_target.id
	return stimulus
