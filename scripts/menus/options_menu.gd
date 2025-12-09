extends ZM_BaseMenu

@export var tab_container: TabContainer
@export var cheats_tab := 4

var cheats: bool = true
var dirty: bool = false
var options: GameOptions = GameOptions.new()
var applied_options: GameOptions = GameOptions.new()


func _apply_resolution() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return

	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		return

	# Change the window size to the selected resolution
	get_window().set_size(options.screen_resolution)
	get_viewport().set_size(options.screen_resolution)
	get_window().move_to_center()


func _apply_options() -> void:
	if options.screen_resolution != applied_options.screen_resolution:
		_apply_resolution()

	applied_options = options.duplicate_deep()


func _set_cheats_visible() -> void:
	tab_container.set_tab_disabled(cheats_tab, !cheats)
	tab_container.set_tab_hidden(cheats_tab, !cheats)


func _ready() -> void:
	on_show()
	_apply_options()


func _on_apply_button_pressed() -> void:
	if dirty:
		_apply_options()

	dirty = false
	options.save_path()
	apply_pressed.emit()


func _on_back_button_pressed() -> void:
	if dirty:
		printerr("TODO: confirm discarding changes")
		dirty = false

	back_pressed.emit()


func on_show() -> void:
	options = GameOptions.load_path()
	_set_cheats_visible()


func on_hide() -> void:
	pass


func on_update() -> void:
	%PhysicalShellsBox.button_pressed = options.physical_casings
	%PhysicalMagsBox.button_pressed = options.physical_mags

	%CRTShader.button_pressed = options.crt_shader

	var resolution_string = "%dx%d" % [options.screen_resolution.x, options.screen_resolution.y]
	var i = 0
	while i < %ResolutionMenu.item_count:
		if %ResolutionMenu.get_item_text(i) == resolution_string:
			%ResolutionMenu.select(i)
			break

		i += 1

	%MainVolumeSlider.value = options.main_volume
	%MusicVolumeSlider.value = options.music_volume
	%EffectsVolumeSlider.value = options.effects_volume


func _on_physical_shells_box_toggled(toggled_on: bool) -> void:
	dirty = true
	options.physical_casings = toggled_on


func _on_physical_mags_box_toggled(toggled_on: bool) -> void:
	dirty = true
	options.physical_mags = toggled_on


func _on_crt_shader_toggled(toggled_on: bool) -> void:
	dirty = true
	options.crt_shader = toggled_on


func _on_resolution_menu_item_selected(index: int) -> void:
	dirty = true

	var resolution = %ResolutionMenu.get_item_text(index)
	var resolution_parts = resolution.split("x")
	options.screen_resolution.x = int(resolution_parts[0])
	options.screen_resolution.y = int(resolution_parts[1])


func _on_main_volume_slider_value_changed(value: float) -> void:
	dirty = true
	options.main_volume = value


func _on_music_volume_slider_value_changed(value: float) -> void:
	dirty = true
	options.music_volume = value


func _on_effects_volume_slider_value_changed(value: float) -> void:
	dirty = true
	options.effects_volume = value


func _on_window_mode_menu_item_selected(_index: int) -> void:
	dirty = true
	# TODO: add to options


func _on_no_clip_box_toggled(_toggled_on: bool) -> void:
	if cheats:
		printerr("TODO: implement noclip cheat")


func _on_god_mode_box_toggled(_toggled_on: bool) -> void:
	if cheats:
		printerr("TODO: implement godmode cheat")


func _on_back_pressed() -> void:
	back_pressed.emit()
