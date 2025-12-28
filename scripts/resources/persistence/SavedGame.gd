extends Resource
class_name ZP_SavedGame

@export var version: int = 1
@export var levels: Dictionary[String, ZP_SavedLevel] = {}
@export var players: Dictionary[String, ZP_SavedEntity] = {}
