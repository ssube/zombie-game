// Shimmer highlight shader
//
// from https://godotshaders.com/shader/3d-item-highlighter-easier-to-adjust-supports-all-directions/
// by https://godotshaders.com/author/wsnordenmark/
// licensed under MIT

/*
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

shader_type spatial;
render_mode unshaded, depth_draw_never;

global uniform float shimmer_time = 0.0;

group_uniforms Highlight;
uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_speed : hint_range(0, 25) = 1.0;
uniform float shine_width : hint_range(0, 2) = 1.0;
uniform float cycle_interval : hint_range(0, 100) = 1.0;
uniform float angle_fade : hint_range(0, 1) = 1.0;

group_uniforms HighlightDirection;
uniform float x_direction : hint_range(-1, 1) = 0.0;
uniform float y_direction : hint_range(-1, 1) = 0.0;
uniform float z_direction : hint_range(-1, 1) = 1.0;

float sawtooth(float x) {
	float time_since = TIME - shimmer_time;
	return 2.0 * ( (x + shine_speed * time_since) / (shine_width + cycle_interval) - floor( 0.5 + (x + shine_speed * time_since) / (shine_width + cycle_interval) ) );
}

void fragment() {
	vec3 w_vertex = ( INV_VIEW_MATRIX * vec4(VERTEX, 1.0) ).xyz;

	float projection = dot( w_vertex, normalize(vec3(x_direction, y_direction, z_direction)) );

	float frequency = ceil( sawtooth(projection) - sawtooth(projection + shine_width) );

	ALBEDO = shine_color.xyz;
	ALPHA = clamp( ( 1.0 - dot(NORMAL, VIEW) * angle_fade) * frequency * shine_color.a, 0.0, 1.0 );
}
