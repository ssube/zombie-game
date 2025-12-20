extends Component
class_name ZC_Attention

## Attention scoring configuration
@export var faction_scores: Dictionary[StringName, float] = {
		Constants.FACTION_PLAYERS: 1.0,
		Constants.FACTION_SURVIVORS: 0.7,
		Constants.FACTION_DOORS: 0.5,
		Constants.FACTION_ZOMBIES: 0.5,
		Constants.FACTION_ANIMALS: 0.3,
		Constants.FACTION_OBJECTS: 0.2,  # Thrown rocks, etc.
}

## Type multipliers (stacks with faction score)
@export var type_multipliers: Dictionary[int, float] = {
		ZC_Stimulus.StimulusType.TOOK_DAMAGE: 2.0,
		ZC_Stimulus.StimulusType.SAW_ENTITY: 1.0,
		ZC_Stimulus.StimulusType.SAW_AGGRESSIVE_ALLY: 0.8,
		ZC_Stimulus.StimulusType.HEARD_SOUND: 0.6,
}

## Decay rate for leaky integrator (0.0-1.0, lower = slower decay)
@export var decay_rate: float = 0.1

## Minimum score change to trigger target reevaluation
@export var score_change_threshold: float = 0.1

@export_group("State")
## Current attention score (0.0 = unaware, 1.0 = fully alert)
@export var score: float = 0.0

@export var has_target_entity: bool = false

## Current target (may be null if only heard a sound)
@export var target_entity: String = "":
	set(value):
		target_entity = value
		if target_entity != "":
			has_target_entity = true
		else:
			has_target_entity = false

@export var has_target_position: bool = false

## Last known position of interest (always set, even for sounds)
@export var target_position: Vector3 = Vector3.ZERO:
	set(value):
		target_position = value
		has_target_position = true

## Time since last stimulus (for "giving up" behavior)
@export var time_since_stimulus: float = 0.0

## Previous frame's score (for change detection)
var previous_score: float = 0.0
