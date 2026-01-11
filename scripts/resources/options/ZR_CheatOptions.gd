extends Resource
class_name ZR_CheatOptions

@export var enabled: bool = false

@export_group("Player Cheats")
@export var no_aggro: bool = false
@export	var no_clip: bool = false
@export	var god_mode: bool = false

@export_group("Debug Options")
@export var show_fsm_states: bool = true
@export var show_nav_mesh: bool = false
@export var show_nav_paths: bool = false
@export var show_perception: bool = false
@export var show_ray_casts: bool = true
@export var show_sounds: bool = false
@export var debug_duration: float = 5.0
