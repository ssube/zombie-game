shader_type spatial;
render_mode unshaded, depth_draw_never;
const int kernelSize = 16;
const vec3 kernel[16] = {
	vec3(0.019026, 0.014279, 0.010519),
	vec3(-0.024865, 0.007903, 0.064579),
	vec3(-0.019492, 0.042650, 0.017825),
	vec3(0.026718, -0.026148, 0.014359),
	vec3(-0.053264, -0.057006, 0.091722),
	vec3(0.056508, -0.080027, 0.052389),
	vec3(-0.114437, 0.013222, 0.105258),
	vec3(0.084779, -0.132078, 0.057769),
	vec3(-0.013898, -0.089416, 0.171408),
	vec3(-0.131400, -0.059863, 0.038088),
	vec3(-0.009884, 0.009850, 0.001457),
	vec3(-0.010069, -0.031745, 0.012010),
	vec3(0.335164, 0.352856, 0.006707),
	vec3(0.348525, 0.232004, 0.126843),
	vec3(0.415091, 0.146300, 0.212393),
	vec3(0.143938, 0.040199, 0.314998)
};

uniform float radius: hint_range(0.0, 5.0) = 0.5;
uniform float bias: hint_range(0.0, 1.0) = 0.025;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, source_color, repeat_disable;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D NORMAL_ROUGHNESS_TEXTURE: hint_normal_roughness_texture, source_color, repeat_disable, filter_nearest;
uniform sampler2D SSAO_NOISE: filter_nearest, repeat_enable, source_color;



float get_depth(vec2 uv, mat4 inv_proj) {
	float depth = texture(DEPTH_TEXTURE, uv).r;
	float linear_depth = 1.0 / (depth * inv_proj[2].w + inv_proj[3].w);
	return linear_depth;
}

vec3 get_position(vec2 uv, mat4 inv_proj_mat) {
	vec4 clipSpacePosition = vec4(uv * 2.0 - 1.0, texture(DEPTH_TEXTURE, uv).r, 1.0);
	vec4 viewSpacePosition = inv_proj_mat * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	return viewSpacePosition.xyz;
}

vec3 get_normal(vec2 uv) {
	vec3 normal = texture(NORMAL_ROUGHNESS_TEXTURE, uv).rgb;
	return (normal - 0.5) * 2.0;
}

void fragment() {
	const vec2 noiseScale = VIEWPORT_SIZE/4.0;
	float occlusionSum = 0.0;

	for (int x=-2; x<2; x++) {
		for (int y=-2; y<2; y++) {
			vec2 uv = SCREEN_UV + vec2(float(x),float(y)) / VIEWPORT_SIZE;
			vec3 fragPos = get_position(uv, INV_PROJECTION_MATRIX);
			vec3 normal = texture(NORMAL_ROUGHNESS_TEXTURE, uv).rgb;
			vec3 randomVec = texture(SSAO_NOISE, uv * noiseScale).xyz;

			vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
			vec3 bitangent = cross(normal, tangent);
			mat3 TBN = mat3(tangent, bitangent, normal);

			float occlusion = 0.0;

			for(int i=0; i < kernelSize; i++) {
				// get sample position
				vec3 sample = TBN * kernel[i];
				sample = fragPos + sample * radius;

				vec4 offset = vec4(sample, 1.0);
				offset = PROJECTION_MATRIX * offset;
				offset.xyz /= offset.w;
				offset.xyz = offset.xyz * 0.5 + 0.5;

				float sampleDepth = get_position(offset.xy, INV_PROJECTION_MATRIX).z;
				float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
				occlusion += (sampleDepth >= sample.z + bias ? 1.0 : 0.0) * rangeCheck;
			}
			occlusion /= float(kernelSize);
			occlusionSum += occlusion;
		}
	}


	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	ALBEDO *= 1.0 - vec3(occlusionSum / 16.0);
}
