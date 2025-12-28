extends Resource
class_name ZP_SavedEntity

@export_group("ECS Data")
@export var components: Array[ZP_SavedComponent] = []
@export var inventory: Array[ZP_SavedEntity] = []
@export var relationships: Array[ZP_SavedRelationship] = []

@export_group("Node Data")
@export var transform: Transform3D = Transform3D.IDENTITY
