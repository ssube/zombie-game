class_name TreeUtils

static func get_game(node: Node) -> ZN_World:
	return node.get_tree().root.get_node("/root/Game") as ZN_World

static func get_level(node: Node) -> Node:
	return get_game(node).get_node("Level")

static func get_menu(node: Node) -> ZM_BaseMenu:
	return get_game(node).get_node("Menu") as ZM_BaseMenu
