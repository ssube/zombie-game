extends Component
class_name ZC_Input


@export_group("Configuration")
## Base walking speed in meters per second.
@export var walk_speed := 5.0
## Speed multiplier applied when sprinting.
@export var sprint_multiplier := 1.5
## Speed multiplier applied when crouching.
@export var crouch_multiplier := 0.5
## Initial vertical velocity applied when jumping.
@export var jump_speed := 5.0

## The amount of time (in seconds) after leaving a surface during which the character can still jump.
@export var coyote_time: float = 0.1

@export_group("Movement")
## Normalized input direction for horizontal movement (x = strafe, y = forward/back).
@export var move_direction: Vector2 = Vector2.ZERO
## Rotation input for camera/body turning (x = pitch, y = yaw, z = roll).
@export var turn_direction: Vector3 = Vector3.ZERO
## Whether the jump input is pressed this frame.
@export var move_jump: bool = false
## Whether the crouch input is pressed this frame.
@export var move_crouch: bool = false
## Whether the sprint input is pressed this frame.
@export var move_sprint: bool = false

@export_group("Actions")
## Whether the attack input is pressed this frame.
@export var use_attack: bool = false
## Whether the interact input is pressed this frame.
@export var use_interact: bool = false
## Whether the flashlight toggle input is pressed this frame.
@export var use_light: bool = false
## Whether the heal input is pressed this frame.
@export var use_heal: bool = false
## Whether the holster weapon input is pressed this frame.
@export var use_holster: bool = false
## Whether the pickup input is pressed this frame.
@export var use_pickup: bool = false
## Whether the reload input is pressed this frame.
@export var use_reload: bool = false

## Returns true if any action input is pressed this frame.
@export var use_any: bool:
	get():
		return (
			use_attack or
			use_interact or
			use_light or
			use_heal or
			use_holster or
			use_pickup or
			use_reload
		)

@export_group("Attacks")
## Whether use_attack was true in the previous frame.
@export var was_attacking: bool = false
## Whether an attack is starting this frame.
@export var attack_starting: bool = false
## Whether an attack is ending this frame.
@export var attack_ending: bool = false
## How long (in seconds) the attack button has been held down.
@export var attack_held_duration: float = 0.0

@export_group("Menus")
## Whether the pause menu input is pressed this frame.
@export var menu_pause: bool = false
## Whether the inventory menu input is pressed this frame.
@export var menu_inventory: bool = false
## Whether the objectives menu input is pressed this frame.
@export var menu_objectives: bool = false

@export_group("Weapon")
## Whether the next weapon input is pressed this frame.
@export var weapon_next: bool = false
## Whether the previous weapon input is pressed this frame.
@export var weapon_previous: bool = false

@export_group("Shortcuts")
## Maps item shortcut slots to their pressed state this frame.
@export var shortcuts: Dictionary[ZC_ItemShortcut.ItemShortcut, bool] = {}
## Returns true if any item shortcut input is pressed this frame.
@export var any_shortcut: bool:
	get():
		for pressed in shortcuts.values():
			if pressed:
				return true
		return false
