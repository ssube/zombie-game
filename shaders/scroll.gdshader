// Texture scroll effect shader for Godot Engine
//
// original to the Zombie Game project

shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.1); // UV units per second
uniform bool clamp_edges = false;           // true = clamp instead of repeat

void fragment() {
	// Move UV over time.
	vec2 uv = UV + scroll_speed * TIME;

	if (clamp_edges) {
		uv = clamp(uv, vec2(0.0), vec2(1.0));
	} else {
		// Wrap to 0..1 so it tiles.
		uv = fract(uv);
	}

	COLOR = texture(TEXTURE, uv) * COLOR;
}