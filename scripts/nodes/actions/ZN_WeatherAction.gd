extends ZN_BaseAction
class_name ZN_WeatherAction

@export_group("Time")
@export var set_time: bool = false
@export var time_of_day: ZC_Weather.TimeOfDay = ZC_Weather.TimeOfDay.DUSK

@export_group("Weather")
@export var set_weather: bool = false
@export var weather_type: ZC_Weather.WeatherType = ZC_Weather.WeatherType.CLOUDY

func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var weather := actor.get_component(ZC_Weather) as ZC_Weather
	if weather == null:
		return

	if set_time:
		var time_name := ZC_Weather.TimeOfDay.keys()[time_of_day] as String
		print("Changing time of day to %s" % time_name)
		weather.time_of_day = time_of_day

	if set_weather:
		var weather_name := ZC_Weather.WeatherType.keys()[weather_type] as String
		print("Changing weather to %s" % weather_name)
		weather.weather_type = weather_type
