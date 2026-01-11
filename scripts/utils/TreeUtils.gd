class_name TreeUtils


static func get_game(node: Node) -> ZN_World:
	return node.get_tree().root.get_node("/root/Game") as ZN_World


static func get_level(node: Node) -> Node:
	return get_game(node).get_node("Level")


static func get_markers(node: Node) -> Dictionary[String, Marker3D]:
	var level_node := get_level(node)
	if level_node is ZN_Level:
		return level_node.get_markers()

	var markers: Dictionary[String, Marker3D] = {}
	var markers_node := level_node.get_node("Markers")
	if markers_node == null:
		return markers

	for marker in markers_node.get_children():
		if marker is Marker3D:
			markers[marker.name] = marker as Marker3D

	return markers


static func get_menu(node: Node) -> ZM_Menu:
	return get_game(node).get_node("Menu") as ZM_Menu


enum NodeState {
	NONE = 0,
	ACTIVE = 1,
	VISIBLE = 2,
	ENABLED = 4,
	PROCESSING = 8,
}

const ALL_FLAGS: NodeState = NodeState.ACTIVE | NodeState.VISIBLE | NodeState.ENABLED | NodeState.PROCESSING


static func toggle_node(node: Node, state: NodeState = NodeState.NONE, mask: NodeState = NodeState.NONE) -> void:
	if (mask & NodeState.ACTIVE) and "active" in node:
		node.active = (state & NodeState.ACTIVE) != 0

	if (mask & NodeState.VISIBLE) and "visible" in node:
		node.visible = (state & NodeState.VISIBLE) != 0

	if (mask & NodeState.ENABLED) and "disabled" in node:
		node.disabled = (state & NodeState.ENABLED) == 0

	if (mask & NodeState.PROCESSING) and "process_mode" in node:
		if (state & NodeState.PROCESSING):
			node.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			node.process_mode = Node.PROCESS_MODE_DISABLED
