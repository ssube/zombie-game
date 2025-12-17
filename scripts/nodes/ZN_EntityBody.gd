extends PhysicsBody3D

@export var parent_entity: Entity

@export var disabled: bool = false:
	set(value):
		disabled = value
		_disable_children(value)


func _disable_children(value: bool) -> void:
	for child in self.get_children():
		if "disabled" in child:
			child.disabled = value
