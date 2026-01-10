extends Node3D


var previous_enabled: bool = true
var previous_volume: float = 0.0

var compiler_steps: Array[Array] = []
var completed_steps: int = 0

var last_entity: Entity = null


var compiled: bool:
	get():
		return compiler_steps.size() == completed_steps


func _remove() -> void:
	self.get_parent().remove_child(self)
	self.queue_free()


func _update_progress() -> void:
	var ratio := float(completed_steps) / float(compiler_steps.size())
	%ProgressBar.value = ratio * 100.0


func _find_steps() -> int:
	var weapon_effects := ZR_Weapon_Effect.EffectType.keys()

	var weapons_root := %Weapons as Node3D
	for weapon in weapons_root.get_children():
		if weapon is ZE_Weapon:
			for effect_type in weapon_effects:
				compiler_steps.append([weapon, effect_type])

	return compiler_steps.size()


func _enter_tree() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	previous_volume = AudioServer.get_bus_volume_linear(master_bus)
	AudioServer.set_bus_volume_linear(master_bus, 0.0)

	previous_enabled = OptionsManager.options.audio.audio_enabled
	OptionsManager.options.audio.audio_enabled = false


func _exit_tree() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(master_bus, previous_volume)
	OptionsManager.options.audio.audio_enabled = previous_enabled
	# TODO: clear any subtitles that were shown during compilation


func _ready() -> void:
	compiler_steps = []
	_find_steps()


func _process(_delta: float) -> void:
	if compiled:
		_remove()
		return

	if last_entity != null:
		if is_instance_valid(last_entity):
			last_entity.visible = false

		last_entity = null

	var step := compiler_steps[completed_steps]
	var entity := step.pop_front() as Entity
	var params := step

	entity.visible = true
	last_entity = entity

	if entity is ZE_Weapon:
		_process_weapon(entity as ZE_Weapon, params[0] as ZR_Weapon_Effect.EffectType)

	completed_steps += 1
	ZombieLogger.info("Compiled step {0}/{1}", [completed_steps, compiler_steps.size()])
	_update_progress()


func _process_weapon(weapon: ZE_Weapon, effect_type: ZR_Weapon_Effect.EffectType) -> void:
	var effects := weapon.apply_effects(effect_type)
	for effect in effects:
		effect.queue_free()
