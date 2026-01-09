extends Component
class_name ZC_Input


@export_group("Configuration")
@export var walk_speed := 5.0
@export var sprint_multiplier := 1.5
@export var crouch_multiplier := 0.5
@export var jump_speed := 5.0

## The amount of time (in seconds) after leaving a surface during which the character can still jump.
@export var coyote_time: float = 0.1

@export_group("Movement")
@export var move_direction: Vector2 = Vector2.ZERO
@export var turn_direction: Vector3 = Vector3.ZERO
@export var move_jump: bool = false
@export var move_crouch: bool = false
@export var move_sprint: bool = false

@export_group("Actions")
@export var use_attack: bool = false
@export var use_interact: bool = false
@export var use_light: bool = false
@export var use_heal: bool = false
@export var use_holster: bool = false
@export var use_pickup: bool = false
@export var use_reload: bool = false

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
@export var menu_pause: bool = false
@export var menu_inventory: bool = false
@export var menu_objectives: bool = false

@export_group("Weapon")
@export var weapon_next: bool = false
@export var weapon_previous: bool = false

@export_group("Shortcuts")
@export var shortcuts: Dictionary[ZC_ItemShortcut.ItemShortcut, bool] = {}
@export var any_shortcut: bool:
	get():
		for pressed in shortcuts.values():
			if pressed:
				return true
		return false
