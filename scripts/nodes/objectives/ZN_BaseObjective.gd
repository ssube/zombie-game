@abstract
extends Node
class_name ZN_BaseObjective

@export var active: bool = false
@export var title: String = "Replace Me"
@export var optional: bool = false

@abstract func is_completed() -> bool
