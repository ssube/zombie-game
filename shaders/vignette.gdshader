shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap, repeat_enable;

// Center of the vignette in UV space (0–1). (0.5, 0.5) = screen center.
uniform vec2 center = vec2(0.5, 0.5);

// Radius where darkening starts.
uniform float radius : hint_range(0.0, 2.0) = 0.75;

// How soft the edge is. Higher = smoother fade.
uniform float softness : hint_range(0.0001, 1.0) = 0.45;

// Color of the vignette.
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Overall strength of the effect.
uniform float intensity : hint_range(0.0, 2.0) = 1.0;

void fragment()
{
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	
    // Sample the current screen.
    vec4 base_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Centered coordinates in screen space.
    vec2 p = SCREEN_UV - center;

    // Correct for aspect ratio so the vignette stays circular.
    float aspect = screen_size.x / screen_size.y;
    p.x *= aspect;

    float dist = length(p);

    float v = smoothstep(radius - softness, radius, dist);
    vec3 final_rgb = mix(base_color.rgb, vignette_color.rgb, v * intensity * vignette_color.a);

    COLOR = vec4(final_rgb, base_color.a);
}
