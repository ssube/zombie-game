extends Node

var elapsed_delta: float = 0.0
@export var remove_after_duration: float = 1.0


func _process(delta: float) -> void:
	elapsed_delta += delta
	if elapsed_delta >= remove_after_duration:
		var self_node = self.get_node(".")
		if self_node is Node3D:
			self.visible = false

		if self_node is Entity:
			ECS.world.remove_entity(self)

		var parent = self.get_parent()
		parent.remove_child(self)
		self.queue_free()
