class_name ColorUtils

const NAMED_COLORS: Dictionary[String, Color] = {
	&"_world": Color(0.3764706, 0.7764706, 1, 1),
	&"_plot": Color(1, 0.92941177, 0, 1),
	&"_healing": Color(0, 1, 0, 1),
	&"_damage": Color(0.9372549, 0.30980393, 0.52156866, 1),
	&"_special": Color(0.78431374, 0, 0.92156863, 1),
}


static func get_named_color(name: String) -> Color:
	name = name.trim_prefix('"').trim_suffix('"')
		
	if name in NAMED_COLORS:
		return NAMED_COLORS[name]

	return Color(name)
