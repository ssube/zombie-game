extends Node3D

@export var child_entity: Entity
@export var components: Array[Component] = []

func _ready() -> void:
	assert(child_entity != null, "Child entity must be set to copy components!")

	for component in components:
		child_entity.component_resources.append(component)
