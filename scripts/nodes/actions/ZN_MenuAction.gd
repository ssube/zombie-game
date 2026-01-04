extends ZN_BaseAction
class_name ZN_MenuAction

@export var show_menu: bool = true
@export var menu_to_show: ZM_BaseMenu.Menus = ZM_BaseMenu.Menus.PAUSE_MENU

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	var menu := TreeUtils.get_menu(self)
	assert(menu != null, "No menu found for ZN_MenuAction")

	if show_menu:
		menu.show_menu(menu_to_show)
