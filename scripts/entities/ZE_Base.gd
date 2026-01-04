@tool
extends Entity
class_name ZE_Base

@export_tool_button("Generate Instance ID")
var generate_instance_id = _generate_instance_id

@export_tool_button("Save Prefab Path")
var save_prefab_path = _save_prefab_path

@export var extra_components: Array[Component] = []
@export var prefab_path: String = ""

signal action_event(event: Enums.ActionEvent, actor: Node)


func _generate_instance_id() -> void:
	var root := self.owner
	if root == null:
		ZombieLogger.error("Owner is null, cannot generate ID.")
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
	ZombieLogger.info("Generated new entity ID: {0}", [self.id])


func _save_prefab_path() -> void:
	# var current_scene_root = get_tree().current_scene
	var current_scene_root = EditorInterface.get_edited_scene_root()
	if current_scene_root == null:
		push_error("No current scene, cannot save prefab path.")
		return

	var scene_path = current_scene_root.scene_file_path
	self.prefab_path = scene_path
	print("Saved prefab path: ", self.prefab_path)


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
	if self.has_component(ZC_Persistent):
		assert(self.id != "", "Entity instance ID is empty, will not reload correctly")
		assert(self.prefab_path != "", "Prefab path is empty, cannot reload entity from prefab")

	# Not connected until ECS on_ready to make sure components are in place
	action_event.connect(_on_action_event)
	_register_children(self)


func _on_action_event(_entity: Entity, event: Enums.ActionEvent, actor: Node) -> void:
	ActionUtils.run_entity(self, event, actor)


## Typesafe wrapper for action_event.emit(...)
func emit_action(event: Enums.ActionEvent, actor: Node) -> void:
	action_event.emit(self, event, actor)
