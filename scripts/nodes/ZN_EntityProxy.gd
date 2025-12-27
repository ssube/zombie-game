extends Node3D
class_name ZN_EntityProxy

@export var entity: Entity:
	set(value):
		entity = value
		update_children()

@export var targets: Array[Node]

func _ready() -> void:
	update_children()

func update_children() -> void:
	for child in targets:
		# TODO: consolidate on a single name
		if 'entity' in child:
			child.entity = entity
		elif 'parent_entity' in child:
			child.parent_entity = entity
		else:
			assert(false, "Target children must have an entity property!")
