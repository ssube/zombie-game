extends Resource
class_name ZR_GraphicsOptions

enum ShadowCount {
	NONE = 0,
	LOW = 1,
	HIGH = 3,
}

@export var crt_shader: bool = true
@export var screen_resolution: Vector2i = Vector2i(1280, 1024)
@export var shader_resolution: Vector2i = Vector2i(640, 512)
@export var shadow_count: ShadowCount = ShadowCount.HIGH
