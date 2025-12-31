extends Node3D

@export var enabled: bool = true:
	set(value):
		enabled = value
		_set_visible(value)

@export var lights: Array[Light3D] = []


func _ready() -> void:
	_set_visible(enabled)


func _set_visible(value: bool) -> void:
	for light in lights:
		light.visible = value
