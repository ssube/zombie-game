@abstract
@icon("res://textures/icons/obj_objective.svg")
extends Node
class_name ZN_BaseObjective

enum GameState { NONE, WIN, LOSE }

@export var active: bool = false
@export var key: String = ""
@export var title: String = "Replace Me"
@export var optional: bool = false
@export var game_state: GameState = GameState.NONE

@abstract func is_completed() -> bool
