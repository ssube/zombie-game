extends System
class_name ZS_KillstreakSystem

enum StreakMode {
	## Reset streak when character dies (health reaches 0)
	SINCE_LAST_DEATH,
	## Reset streak after a timer expires
	TIMED
}

enum TimerMode {
	## Reset the timer each time a new kill occurs
	RESET_ON_KILL,
	## Extend the timer each time a new kill occurs
	EXTEND_ON_KILL
}

## Killstreak tracking mode
@export var mode: StreakMode = StreakMode.SINCE_LAST_DEATH

## Timer mode (only used when mode is TIMED)
@export var timer_mode: TimerMode = TimerMode.RESET_ON_KILL

## Seconds before streak resets (only used when mode is TIMED)
@export var streak_timeout: float = 5.0

## Track timers per entity (entity ID -> time remaining)
var _entity_timers: Dictionary[String, float] = {}

## Track previous kill counts to detect new kills (entity ID -> kill count)
var _previous_kill_counts: Dictionary[String, int] = {}


func query():
	return q.with_all([ZC_Killstreak])


func process(entities: Array[Entity], _components: Array, delta: float):
	for entity in entities:
		if entity == null:
			continue

		var killstreak := entity.get_component(ZC_Killstreak) as ZC_Killstreak
		if killstreak == null:
			continue

		_process_entity_killstreak(entity, killstreak, delta)


func _process_entity_killstreak(entity: Entity, killstreak: ZC_Killstreak, delta: float) -> void:
	var entity_id := entity.id

	# Check for new kills
	var kill_relationships := _get_kill_relationships(entity)
	var current_kill_count := kill_relationships.size()
	var previous_kill_count := _previous_kill_counts.get(entity_id, 0) as int

	# Detect new kills
	if current_kill_count > previous_kill_count:
		var new_kills := current_kill_count - previous_kill_count
		_handle_new_kills(entity, killstreak, new_kills)

	_previous_kill_counts[entity_id] = current_kill_count

	# Handle streak reset based on mode
	match mode:
		StreakMode.SINCE_LAST_DEATH:
			_handle_death_mode(entity, killstreak)
		StreakMode.TIMED:
			_handle_timed_mode(entity, killstreak, delta)


func _get_kill_relationships(entity: Entity) -> Array[Relationship]:
	return entity.get_relationships(RelationshipUtils.any_killed)


func _handle_new_kills(entity: Entity, killstreak: ZC_Killstreak, new_kills: int) -> void:
	var previous_streak := killstreak.current_streak
	var new_streak := previous_streak + new_kills

	# Record and announce each streak level that was crossed
	for streak_level in range(previous_streak + 1, new_streak + 1):
		if streak_level >= 2:
			var current_count := killstreak.streak_records.get(streak_level, 0) as int
			killstreak.streak_records[streak_level] = current_count + 1
			_announce_streak(entity, streak_level)

	# Update current streak
	killstreak.current_streak = new_streak

	# Reset or extend timer in timed mode
	if mode == StreakMode.TIMED:
		match timer_mode:
			TimerMode.RESET_ON_KILL:
				_entity_timers[entity.id] = streak_timeout
			TimerMode.EXTEND_ON_KILL:
				var current_time := _entity_timers.get(entity.id, 0.0) as float
				_entity_timers[entity.id] = current_time + streak_timeout


func _handle_death_mode(entity: Entity, killstreak: ZC_Killstreak) -> void:
	var health := entity.get_component(ZC_Health) as ZC_Health
	if health == null:
		return

	# Reset streak if entity died
	if health.current_health <= 0:
		_reset_streak(entity, killstreak)


func _handle_timed_mode(entity: Entity, killstreak: ZC_Killstreak, delta: float) -> void:
	var entity_id := entity.id

	# Initialize timer if needed
	if not _entity_timers.has(entity_id):
		_entity_timers[entity_id] = streak_timeout

	# Countdown timer
	_entity_timers[entity_id] -= delta

	# Reset streak if timer expired
	if _entity_timers[entity_id] <= 0.0:
		_reset_streak(entity, killstreak)
		_entity_timers[entity_id] = streak_timeout


func _reset_streak(entity: Entity, killstreak: ZC_Killstreak) -> void:
	if killstreak.current_streak > 0:
		print("Killstreak reset for entity: %s (was at %d)" % [entity.id, killstreak.current_streak])
		killstreak.current_streak = 0


func _announce_streak(entity: Entity, streak_level: int) -> void:
	var streak_name := _get_streak_name(streak_level)
	print("Entity %s achieved %s (%d kills)!" % [entity.id, streak_name, streak_level])


func _get_streak_name(streak_level: int) -> String:
	match streak_level:
		2:
			return "DOUBLE KILL"
		3:
			return "TRIPLE KILL"
		4:
			return "MULTI KILL"
		5:
			return "MEGA KILL"
		6:
			return "ULTRA KILL"
		7:
			return "MONSTER KILL"
		_ when streak_level >= 8:
			return "LUDICROUS KILL"
		_:
			return "KILL STREAK"
