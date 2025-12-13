@tool
extends Node3D

enum TexturePriority {
	NORMAL = 0,
	OVERRIDE = 1,
	CHARACTER = 2,
}

## Keyword -> priority
static var texture_keywords: Dictionary[String, int] = {
	"asphalt": 0,
	"brick": 0,
	"carpet": 1,
	"concrete": 0,
	"grass": 1,
	"human": 2,
	"metal": 0,
	"mud": 1,
	"snow": 1,
	"stone": 0,
	"water": 1,
	"wood": 1,
	"zombie": 2,
}

func _func_godot_apply_properties(entity_properties: Dictionary) -> void:
	print("apply properties: ", entity_properties)

	var metadata: Dictionary = self.get_meta("func_godot_mesh_data")
	print("mesh metadata: ", metadata)
	if metadata == null:
		return

	var texture_names: Array[StringName] = metadata.get("texture_names")
	if texture_names.size() > 1:
		push_warning("Map entities should have one texture each!", self.name)

	# Use the value given in the entity properties, if any
	var surface_type := entity_properties.get("surface_type", "") as String
	if surface_type:
		set_meta("surface_type", surface_type)
		return

	# Otherwise, find the value with the highest priority in the lookup table
	var best_keyword := &"unknown"
	var best_priority := -1

	for texture_name in texture_names:
		var lower_name := texture_name.to_lower()
		for keyword in texture_keywords.keys():
			if keyword in lower_name:
				print("Texture name %s contains keyword %s" % [texture_name, keyword])
				var priority := texture_keywords.get(keyword) as int
				if priority > best_priority:
					best_keyword = keyword
					best_priority = priority

	# Log and apply to the body node
	print("Selected best keyword %s with priority of %d" % [best_keyword, best_priority])
	set_meta("surface_type", best_keyword)
