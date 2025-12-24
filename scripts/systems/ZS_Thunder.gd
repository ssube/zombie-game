extends System
class_name ZS_ThunderSystem

@export var thunder_curve: Curve
@export var thunder_curve_duration: float = 10.0

func query() -> QueryBuilder:
	return q.with_all([{
		ZC_Weather: {
			"weather_type": {
				"_eq": ZC_Weather.WeatherType.THUNDER,
			},
		},
	}])

func process(_entities: Array[Entity], _components: Array, _delta: float) -> void:
	printerr("TODO: implement thunder")
	self.active = false
