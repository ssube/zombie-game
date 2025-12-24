extends Component
class_name ZC_Weather

enum TimeOfDay {
	CUSTOM,
	DAWN,
	DAY,
	DUSK,
	NIGHT,
}

enum WeatherType {
	CUSTOM,
	CLEAR,
	CLOUDY,
	RAIN,
	THUNDER,
	SNOW,
}

@export var time_of_day: TimeOfDay = TimeOfDay.DUSK:
	set(value):
		var previous_time := time_of_day
		time_of_day = value
		if previous_time != time_of_day:
			property_changed.emit(self, "time_of_day", previous_time, time_of_day)

@export var weather_type: WeatherType = WeatherType.CLOUDY:
	set(value):
		var previous_weather := weather_type
		weather_type = value
		if previous_weather != weather_type:
			property_changed.emit(self, "weather_type", previous_weather, weather_type)
