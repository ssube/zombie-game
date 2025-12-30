// Invert effect shader for Godot Engine
//
// from: original to the Zombie Game project
// licensed under GPL-3.0

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap, repeat_enable;

void fragment() {
    vec2 uv = SCREEN_UV;
	vec3 col = texture(SCREEN_TEXTURE, uv).rgb;
	COLOR = vec4(1.0 - col, 1.0);
}
