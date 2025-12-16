extends Component
class_name ZC_Button

@export var is_active: bool = true
@export var is_toggle: bool = false

@export_group("Timers")
## How long after being pressed until the button can be pressed again
@export var cooldown_delay: float = 1.0

## How long after being pressed until the button is released
@export var reset_delay: float = 0.2

@export_group("State")
@export var is_pressed: bool = false:
	set(value):
		var old_value := is_pressed
		is_pressed = value
		if old_value != value:
			property_changed.emit(self, "is_pressed", old_value, value)
