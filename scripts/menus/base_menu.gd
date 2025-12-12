extends Control
class_name ZM_BaseMenu

enum Menus {
	NONE,
	START_MENU,
	PAUSE_MENU,
	INVENTORY_MENU,
	OBJECTIVES_MENU,
	LOADING_MENU,
	GAME_OVER_MENU,
	LOAD_MENU,
	SAVE_MENU,
	OPTIONS_MENU,
	EXIT_DIALOG,
}

enum Effects {
	NONE,
	DAMAGE,
	VIGNETTE,
	WATER,
	FIRE,
	ACID,
}

signal apply_pressed()
signal back_pressed()
signal menu_changed(menu: Menus)


func on_hide() -> void:
	self.visible = false


func on_show() -> void:
	on_update()


func on_update() -> void:
	assert(false, "Menus must override the update method")
