extends Node

@export var options: ZR_Options = ZR_Options.new()

func apply_pending(previous_options: ZR_Options) -> bool:
	apply_volume()

	if options.graphics.screen_resolution != previous_options.graphics.screen_resolution:
		apply_resolution()

	if options.graphics.shader_resolution != previous_options.graphics.shader_resolution:
		apply_shader_resolution()

	return true

func apply_resolution() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return

	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		return

	# Change the window size to the selected resolution
	get_window().set_size(options.graphics.screen_resolution)
	get_viewport().set_size(options.graphics.screen_resolution)
	get_window().move_to_center()


func apply_shader_resolution() -> void:
	var resolution := options.graphics.shader_resolution
	RenderingServer.global_shader_parameter_set("crt_resolution", resolution)


func apply_volume() -> void:
	var master_bus_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(master_bus_index, options.audio.main_volume / 100.0)

	var music_bus_index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(music_bus_index, options.audio.music_volume / 100.0)

	var effects_bus_index := AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_linear(effects_bus_index, options.audio.effects_volume / 100.0)


func toggle_cheat_no_aggro(_value: bool) -> void:
	if not options.cheats.enabled:
		return

	pass

func toggle_cheat_no_clip(value: bool) -> void:
	if not options.cheats.enabled:
		return

	var players := EntityUtils.get_players()
	for player in players:
		var character_player := player.get_node(".") as CharacterBody3D
		var physics_player := player.get_node(".") as PhysicsBody3D
		print("Enabling no-clip for player %s" % player.name)
		physics_player.set_collision_layer_value(4, not value)
		physics_player.set_collision_layer_value(8, value)
		physics_player.set_collision_mask_value(1, not value)
		physics_player.disable_mode = PhysicsBody3D.DISABLE_MODE_MAKE_STATIC
		if value:
			character_player.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
			physics_player.process_mode = PhysicsBody3D.PROCESS_MODE_DISABLED
		else:
			character_player.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
			physics_player.process_mode = PhysicsBody3D.PROCESS_MODE_INHERIT

		for child in physics_player.get_children():
			if child is CollisionShape3D:
				child.disabled = value

func toggle_cheat_god_mode(_value: bool) -> void:
	if not options.cheats.enabled:
		return

	pass
