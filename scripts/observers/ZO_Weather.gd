extends Observer
class_name ZO_WeatherObserver

# TODO: build a cache map of other groups (all except X)
var other_groups: Dictionary[String, Array] = {
	"time_custom": ["time_dawn", "time_day", "time_dusk", "time_night"],
	"time_dawn": ["time_custom", "time_day", "time_dusk", "time_night"],
	"time_day": ["time_custom", "time_dawn", "time_dusk", "time_night"],
	"time_dusk": ["time_custom", "time_dawn", "time_day", "time_night"],
	"time_night": ["time_custom", "time_dawn", "time_day", "time_dusk"],
	"weather_custom": ["weather_clear", "weather_cloudy", "weather_rain", "weather_thunder", "weather_snow"],
	"weather_clear": ["weather_custom", "weather_cloudy", "weather_rain", "weather_thunder", "weather_snow"],
	"weather_cloudy": ["weather_custom", "weather_clear", "weather_rain", "weather_thunder", "weather_snow"],
	"weather_rain": ["weather_custom", "weather_clear", "weather_cloudy", "weather_thunder", "weather_snow"],
	"weather_thunder": ["weather_custom", "weather_clear", "weather_cloudy", "weather_rain", "weather_snow"],
	"weather_snow": ["weather_custom", "weather_clear", "weather_cloudy", "weather_rain", "weather_thunder"],
}

# TODO: attach fog and rain particles to each player
@export var rain_system: System = null
@export var thunder_system: ZS_ThunderSystem = null


func watch() -> Resource:
	return ZC_Weather


func on_component_changed(
	entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant
) -> void:
	match property:
		"time_of_day":
			_time_of_day_changed(entity, component, new_value, old_value)
		"weather_type":
			_weather_type_changed(entity, component, new_value, old_value)


func _time_of_day_changed(_entity: Entity, component: ZC_Weather, new_value: Variant, _old_value: Variant) -> void:
	var time_name := ZC_Weather.TimeOfDay.keys()[new_value] as String
	var time_group := "time_%s" % time_name.to_lower()

	var group_nodes := get_tree().get_nodes_in_group(time_group)
	print("Time group %s has %d nodes" % [time_name, group_nodes.size()])
	for node in group_nodes:
		_toggle_node(node, true)

	var other_group_names := other_groups[time_group]
	for other_name in other_group_names:
		group_nodes = get_tree().get_nodes_in_group(other_name)
		for node in group_nodes:
			_toggle_node(node, false)

	_set_level_environment(component)
	_call_level_hook(component)


func _weather_type_changed(_entity: Entity, component: ZC_Weather, new_value: Variant, _old_value: Variant) -> void:
	var weather_name := ZC_Weather.WeatherType.keys()[new_value] as String
	var weather_group := "weather_%s" % weather_name.to_lower()
	var group_nodes := get_tree().get_nodes_in_group(weather_group)
	print("Weather group %s has %d nodes" % [weather_name, group_nodes.size()])
	for node in group_nodes:
		_toggle_node(node, true)

	var other_group_names := other_groups[weather_group]
	for other_name in other_group_names:
		group_nodes = get_tree().get_nodes_in_group(other_name)
		for node in group_nodes:
			_toggle_node(node, false)


	if rain_system:
		rain_system.active = (new_value == ZC_Weather.WeatherType.RAIN)

	if thunder_system and OptionsManager.options.gameplay.enable_thunder:
		thunder_system.active = (new_value == ZC_Weather.WeatherType.THUNDER)

	_set_level_environment(component)
	_call_level_hook(component)


func _toggle_node(node: Node, enabled: bool) -> void:
	if "active" in node:
		node.active = enabled

	if "visible" in node:
		node.visible = enabled


func _set_level_environment(component: ZC_Weather) -> void:
	var level_node := TreeUtils.get_level(self).get_child(0)
	assert(level_node is ZN_Level, "Level does not inherit from ZN_Level, changing the environment is not supported!")
	if level_node is not ZN_Level:
		return

	var level := level_node as ZN_Level
	var environment := _find_best_environment(level, component)
	if environment == null:
		printerr("No matching environment for conditions %d and %d" % [component.time_of_day, component.weather_type])
		return

	var level_environment := level.get_node(level.environment_node)
	for child in level_environment.get_children():
		child.queue_free()
		level_environment.remove_child(child)

	var environment_scene := environment.environment_scene.instantiate() as Node
	level_environment.add_child(environment_scene)


func _call_level_hook(weather: ZC_Weather) -> void:
	# call a callback within the level node, if it exists
	# TODO: find a better way to do this, like a signal or a level-specific observer
	var level_node := TreeUtils.get_level(self)
	if "set_weather" in level_node:
		level_node.set_weather(weather)


func _find_best_environment(level: ZN_Level, component: Component) -> ZR_Weather:
	var matching_environment: ZR_Weather = null

	# look for a strict match first
	for environment in level.environment_scenes:
		if _match_environment(component, environment, true):
			matching_environment = environment
			break

	if matching_environment:
		return matching_environment

	# followed by a wildcard match
	for environment in level.environment_scenes:
		if _match_environment(component, environment):
			matching_environment = environment
			break

	if matching_environment:
		return matching_environment

	# finally, look for a fallback environment
	for environment in level.environment_scenes:
		if environment.time_of_day == ZC_Weather.TimeOfDay.ANY and environment.weather_type == ZC_Weather.WeatherType.ANY:
			matching_environment = environment
			break

	return matching_environment


func _match_environment(component: ZC_Weather, environment: ZR_Weather, strict: bool = false) -> bool:
	if environment.time_of_day == component.time_of_day and environment.weather_type == component.weather_type:
		return true

	if strict:
		return false

	if environment.weather_type == component.weather_type and environment.time_of_day == ZC_Weather.TimeOfDay.ANY:
		return true

	if environment.time_of_day == component.time_of_day and environment.weather_type == ZC_Weather.WeatherType.ANY:
		return true

	return false
