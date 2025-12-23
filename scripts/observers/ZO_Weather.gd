extends Observer
class_name ZO_WeatherObserver

func watch() -> Resource:
	return ZC_Weather


func on_component_changed(
	entity: Entity, component: Resource, property: String, new_value: Variant, old_value: Variant
) -> void:
	pass
