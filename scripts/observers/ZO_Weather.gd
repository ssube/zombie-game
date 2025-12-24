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

	_call_level_hook(component)


func _toggle_node(node: Node, enabled: bool) -> void:
	if node is WorldEnvironment:
		if enabled:
			node.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			node.process_mode = Node.PROCESS_MODE_DISABLED

	if node is VisualInstance3D:
		node.visible = enabled


func _call_level_hook(weather: ZC_Weather) -> void:
	# call a callback within the level node, if it exists
	# TODO: find a better way to do this, like a signal or a level-specific observer
	var level_node := TreeUtils.get_level(self)
	if "set_weather" in level_node:
		level_node.set_weather(weather)
