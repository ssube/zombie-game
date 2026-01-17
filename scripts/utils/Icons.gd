class_name Icons

static var item_ammo := preload("res://textures/600 Minimal icons/PNG Light/Icon set 3/0.5x/Ammo 256px.png") as Texture2D
static var item_armor := preload("res://textures/600 Minimal icons/PNG Light/Icon set 2/0.5x/Armor 256 px.png") as Texture2D
static var item_food := preload("res://textures/600 Minimal icons/PNG Light/Food and drinks/0.5x/Chicken 256 px.png") as Texture2D
# or res://textures/600 Minimal icons/PNG Light/Set 4 (New Update)/256 px/Health 256 px.png
static var item_weapon_melee := preload("res://textures/600 Minimal icons/PNG Light/Icon set 2/0.5x/Sword 7 256 px.png") as Texture2D
static var item_weapon_ranged := preload("res://textures/600 Minimal icons/PNG Light/Icon set 3/0.5x/Shut gun 256px.png") as Texture2D

static var concept_button := preload("res://textures/600 Minimal icons/PNG Light/Set 4 (New Update)/256 px/Radio button check  256 px.png") as Texture2D
static var concept_experience := preload("res://textures/600 Minimal icons/PNG Light/Set 4 (New Update)/256 px/XP 256 px.png") as Texture2D
static var concept_gift := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Gift 256 px.png") as Texture2D
static var concept_key := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Key 256 px.png") as Texture2D # TODO: rename to item_key
static var concept_lock := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Lock 256 px.png") as Texture2D
static var concept_save := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Save 256 px.png") as Texture2D
static var concept_unlock := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Unlock  256 px.png") as Texture2D

# TODO: rename to category
static var message_chat := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Message 256 px.png") as Texture2D
static var message_subtitle := preload("res://textures/600 Minimal icons/PNG Light/Icon set 3/0.5x/Headphone 256px.png") as Texture2D
static var message_system := preload("res://textures/600 Minimal icons/PNG Light/Icon set 3/0.5x/Info 256px.png") as Texture2D

static var level_info := preload("res://textures/600 Minimal icons/PNG Light/Icon set 3/0.5x/Info 256px.png") as Texture2D
static var level_question := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Question 256 px.png") as Texture2D
static var level_warning := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Exclamation sign 256 px.png") as Texture2D
static var level_error := preload("res://textures/600 Minimal icons/PNG Light/Icon set 1/0.5x/Danger sign 1 256 px.png") as Texture2D


static func get_weapon_icon(weapon: Entity) -> Texture2D:
	if EntityUtils.is_ranged_weapon(weapon):
		return item_weapon_ranged
	else:
		return item_weapon_melee
