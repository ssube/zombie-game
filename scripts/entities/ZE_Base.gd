@tool
extends Entity
class_name ZE_Base

@export_tool_button("Generate Instance ID")
var generate_instance_id = _generate_instance_id

@export var extra_components: Array[Component] = []

signal action_event(event: Enums.ActionEvent, actor: Node)

func _generate_instance_id() -> void:
	var root := self.owner
	if root == null:
		push_error("Owner is null, cannot generate ID.")
		return

	var script := self.get_script() as Script
	var type = script.get_global_name()

	var time: int = floor(Time.get_unix_time_from_system())
	var salt: int = randi() % 100000

	var parts = [
		owner.name,
		type,
		str(time),
		str(salt)
	]
	self.id = "_".join(parts)
	print("Generated new entity ID: ", self.id)


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	self.component_resources.append_array(self.extra_components)


func _register_children(node: Node) -> void:
	for child in node.get_children():
		# register entities and let them register their own children, recurse into other nodes
		if child is Entity:
			ECS.world.add_entity(child)
		else:
			_register_children(child)


func on_ready() -> void:
	action_event.connect(_on_action_event)
	_register_children(self)


func _on_action_event(event: Enums.ActionEvent, actor: Node) -> void:
	if actor is not Entity:
		return

	ActionUtils.run_entity(self, event, actor)
