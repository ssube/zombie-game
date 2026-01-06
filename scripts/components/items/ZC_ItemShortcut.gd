extends Component
class_name ZC_ItemShortcut

enum ItemShortcut {
	SHORTCUT_1,
	SHORTCUT_2,
	SHORTCUT_3,
	SHORTCUT_4,
	SHORTCUT_5,
	SHORTCUT_6,
	SHORTCUT_7,
	SHORTCUT_8,
	SHORTCUT_9,
	SHORTCUT_10,
	SHORTCUT_11,
	SHORTCUT_12,
	# add a bit of a gap
	SHORTCUT_HEALING = 100,
}

const FIRST_LOOP_SHORTCUT: ItemShortcut = ItemShortcut.SHORTCUT_1
const LAST_LOOP_SHORTCUT: ItemShortcut = ItemShortcut.SHORTCUT_12


@export var shortcut: ItemShortcut = ItemShortcut.SHORTCUT_1


static func next_shortcut(value: ItemShortcut) -> ItemShortcut:
	var next_value := int(value) + 1
	if next_value > int(LAST_LOOP_SHORTCUT):
		next_value = int(FIRST_LOOP_SHORTCUT)
	return next_value as ItemShortcut


static func previous_shortcut(value: ItemShortcut) -> ItemShortcut:
	var prev_value := int(value) - 1
	if prev_value < int(FIRST_LOOP_SHORTCUT):
		prev_value = int(LAST_LOOP_SHORTCUT)
	return prev_value as ItemShortcut
