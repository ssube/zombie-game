extends Resource
class_name ZP_SavedLevel

@export var entities: Dictionary[String, ZP_SavedEntity] = {}
@export var objectives: ZP_SavedObjectives
@export var deleted: Array[String] = []
