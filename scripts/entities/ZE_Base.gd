@tool
extends Entity
class_name ZE_Base

@export_tool_button("Generate ID")
var generate_id = _generate_id

func _generate_id() -> void:
	var root := self.owner
	if root == null:
		push_error("Owner is null, cannot generate ID.")
		return

	var script := self.get_script() as Script
	var type = script.get_global_name()

	var time: int = floor(Time.get_unix_time_from_system())
	var salt: int = randi() % 100000

	var id_parts = [
		owner.name,
		type,
		str(time),
		str(salt)
	]
	self.id = "_".join(id_parts)
	print("Generated new entity ID: ", self.id)

func on_ready() -> void:
	if self.id == "":
		printerr("Entity ID is empty, will not persist in saved state: ", self)
