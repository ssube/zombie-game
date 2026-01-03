@tool
extends Control

var diagram_elements := []
var diagram_font_size := 16

func _draw():
	for element in diagram_elements:
		var rect: Rect2 = element["rect"]
		var label: String = element["label"]
		var outline: Color = element["outline"]

		# Draw outline if color is set
		if outline != Color.TRANSPARENT:
			# Use draw_rect with filled=false for outline
			draw_rect(rect, outline, false, 2.0)

		# Draw label if set
		if label != "":
			var label_color := outline if outline != Color.TRANSPARENT else Color.WHITE
			var center := rect.position + rect.size / 2

			# Get font and calculate text size
			var font := ThemeDB.fallback_font
			var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, diagram_font_size)

			# Center the text
			var text_pos := center - text_size / 2
			text_pos.y += text_size.y * 0.75

			# Draw outline for text (black outline for readability)
			draw_string_outline(font, text_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, diagram_font_size, 2, Color.BLACK)
			# Draw the text itself
			draw_string(font, text_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, diagram_font_size, label_color)
