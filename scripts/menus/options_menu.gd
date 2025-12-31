extends ZM_BaseMenu

@export var tab_container: TabContainer
@export var active_tab := 0:
	get():
		return $MarginContainer/VBoxContainer/TabContainer.current_tab
	set(value):
		$MarginContainer/VBoxContainer/TabContainer.current_tab = value
@export var cheats_tab := 4


var _applied_options: ZR_Options
var _current_options: ZR_Options
var _dirty: bool = false
var _play_audio: bool = false


func _apply_options() -> void:
	OptionsManager.apply_pending(_applied_options)
	_applied_options = OptionsManager.options.duplicate_deep()


func _set_cheats_visible(tab_visible: bool = false) -> void:
	tab_container.set_tab_disabled(cheats_tab, !tab_visible)
	tab_container.set_tab_hidden(cheats_tab, !tab_visible)


func _ready() -> void:
	on_show()
	_apply_options()


func _on_apply_button_pressed() -> void:
	if _dirty:
		_apply_options()

	_dirty = false
	OptionsManager.options.save_path()
	apply_pressed.emit()


func _on_back_button_pressed() -> void:
	if _dirty:
		printerr("TODO: confirm discarding changes")
		_dirty = false

	back_pressed.emit()


func on_show() -> void:
	OptionsManager.options = ZR_Options.load_path()
	_applied_options = OptionsManager.options.duplicate_deep()
	_current_options = OptionsManager.options
	super.on_show()
	_play_audio = true


func on_hide() -> void:
	_play_audio = false


func on_update() -> void:
	_current_options = OptionsManager.options
	_set_cheats_visible(_current_options.cheats.enabled)

	%PhysicalShellsBox.button_pressed = _current_options.gameplay.physical_casings
	%PhysicalMagsBox.button_pressed = _current_options.gameplay.physical_mags

	%CRTShader.button_pressed = _current_options.graphics.crt_shader

	var resolution_string = "%dx%d" % [
		_current_options.graphics.screen_resolution.x,
		_current_options.graphics.screen_resolution.y,
	]
	var i = 0
	while i < %ResolutionMenu.item_count:
		if %ResolutionMenu.get_item_text(i) == resolution_string:
			%ResolutionMenu.select(i)
			break

		i += 1

	var shader_resolution_string = "%dx%d" % [
		_current_options.graphics.shader_resolution.x,
		_current_options.graphics.shader_resolution.y,
	]
	i = 0
	while i < %ShaderResolutionMenu.item_count:
		if %ShaderResolutionMenu.get_item_text(i) == shader_resolution_string:
			%ResolutionMenu.select(i)
			break

		i += 1

	%MainVolumeSlider.value = _current_options.audio.main_volume
	%MusicVolumeSlider.value = _current_options.audio.music_volume
	%EffectsVolumeSlider.value = _current_options.audio.effects_volume
	%SubtitleCheckBox.button_pressed = _current_options.audio.subtitles
	%AdaptiveAimSlider.value = _current_options.gameplay.adaptive_aim


func _on_physical_shells_box_toggled(toggled_on: bool) -> void:
	_dirty = true
	_current_options.gameplay.physical_casings = toggled_on


func _on_physical_mags_box_toggled(toggled_on: bool) -> void:
	_dirty = true
	_current_options.gameplay.physical_mags = toggled_on


func _on_crt_shader_toggled(toggled_on: bool) -> void:
	_dirty = true
	_current_options.graphics.crt_shader = toggled_on


func _on_resolution_menu_item_selected(index: int) -> void:
	_dirty = true

	var resolution = %ResolutionMenu.get_item_text(index)
	var resolution_parts = resolution.split("x")
	_current_options.graphics.screen_resolution.x = int(resolution_parts[0])
	_current_options.graphics.screen_resolution.y = int(resolution_parts[1])

	_on_shader_resolution_menu_item_selected(index) # indexes must match
	%ShaderResolutionMenu.select(index)


func _on_shader_resolution_menu_item_selected(index: int) -> void:
	_dirty = true

	var resolution = %ShaderResolutionMenu.get_item_text(index)
	var resolution_parts = resolution.split("x")
	_current_options.graphics.shader_resolution.x = int(resolution_parts[0])
	_current_options.graphics.shader_resolution.y = int(resolution_parts[1])


func _on_main_volume_slider_value_changed(value: float) -> void:
	_dirty = true
	_current_options.audio.main_volume = value
	# TODO: debounce
	if _play_audio:
		OptionsManager.apply_volume()
		%MainPreviewPlayer.play()


func _on_music_volume_slider_value_changed(value: float) -> void:
	_dirty = true
	_current_options.audio.music_volume = value
	# TODO: debounce
	if _play_audio:
		OptionsManager.apply_volume()
		%MusicPreviewPlayer.play()


func _on_effects_volume_slider_value_changed(value: float) -> void:
	_dirty = true
	_current_options.audio.effects_volume = value
	# TODO: debounce
	if _play_audio:
		OptionsManager.apply_volume()
		%EffectsPreviewPlayer.play()


func _on_window_mode_menu_item_selected(_index: int) -> void:
	_dirty = true
	# TODO: add to options


func _on_no_aggro_box_toggled(toggled_on: bool) -> void:
	OptionsManager.toggle_cheat_no_aggro(toggled_on)


func _on_no_clip_box_toggled(toggled_on: bool) -> void:
	OptionsManager.toggle_cheat_no_clip(toggled_on)


func _on_god_mode_box_toggled(toggled_on: bool) -> void:
	OptionsManager.toggle_cheat_god_mode(toggled_on)


func _on_back_pressed() -> void:
	back_pressed.emit()


func _on_subtitle_check_box_toggled(toggled_on: bool) -> void:
	_dirty = true
	_current_options.audio.subtitles = toggled_on


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	_dirty = true
	_current_options.controls.mouse_sensitivity = round(value)


func _on_adaptive_aim_slider_value_changed(value: float) -> void:
	_dirty = true
	_current_options.gameplay.adaptive_aim = value
