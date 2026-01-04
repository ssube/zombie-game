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
