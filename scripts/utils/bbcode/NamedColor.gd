@tool
extends RichTextEffect
class_name ZBB_NamedColorTextEffect

# Syntax: [named_color color_name="red"]Text[/named_color]

var bbcode: String = "named_color"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var color_name: String = char_fx.env.get("name", "")
	if color_name == "":
		return false

	var color: Color = ColorUtils.get_named_color(color_name)
	char_fx.color = color
	return true
