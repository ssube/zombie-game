extends Component
class_name ZC_Input

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

@export_group("Menus")
@export var menu_pause: bool = false
@export var menu_inventory: bool = false
@export var menu_objectives: bool = false

@export_group("Speed")
@export var walk_speed := 5.0
@export var sprint_multiplier := 1.5
@export var crouch_multiplier := 0.5
@export var jump_speed := 5.0

@export_group("Weapon")
@export var weapon_next: bool = false
@export var weapon_previous: bool = false
