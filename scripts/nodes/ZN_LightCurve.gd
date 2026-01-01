@tool
extends ZN_LightGroup
class_name ZN_LightCurve

@export var duration: float = 1.0
@export var loop: bool = true

@export var energy_curve: Curve
@export var color_curve: Gradient

var _time_elapsed: float = 0.0

func _process(delta: float) -> void:
	if not enabled:
		return

	_time_elapsed += delta
	if _time_elapsed > duration:
		if loop:
			_time_elapsed -= duration
		else:
			return

	var ratio := _time_elapsed / duration
	var energy := energy_curve.sample(ratio)
	var color := color_curve.sample(ratio)

	for light in lights:
		light.light_energy = energy
		light.light_color = color
