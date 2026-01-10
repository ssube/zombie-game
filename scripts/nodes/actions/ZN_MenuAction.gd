extends ZN_BaseAction
class_name ZN_MenuAction

@export var show_menu: bool = true
@export var menu_to_show: ZM_BaseMenu.Menus = ZM_BaseMenu.Menus.PAUSE_MENU
@export var custom_menu: PackedScene = null
@export var custom_menu_pause: bool = true

func run_node(source: Node, event: Enums.ActionEvent, actor: Node) -> void:
	var menu := TreeUtils.get_menu(self)
	assert(menu != null, "No menu found for ZN_MenuAction")

	if show_menu:
		if menu_to_show == ZM_BaseMenu.Menus.CUSTOM_MENU:
			assert(custom_menu != null, "Custom menu is null in ZN_MenuAction")
			menu.show_custom_menu(custom_menu, custom_menu_pause, {
				"action": self,
				"source": source,
				"event": event,
				"actor": actor,
			})
		else:
			menu.show_menu(menu_to_show)
