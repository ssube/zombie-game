extends Node3D

@export var entities: Array[Entity] = []
@export var components: Array[Component] = []

func _ready() -> void:
	assert(entities.size() > 0, "Child entity must be set to copy components!")

	for entity in entities:
		for component in components:
			entity.component_resources.append(component)
