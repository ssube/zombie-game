extends Node
# This script manages impact decals (bullet holes, splatters, etc)

# Mapping of surface types to decal scenes (PackedScene of a Sprite3D)
@export var decal_scenes := {
	"default": preload("res://effects/decals/bullet_hole_metal.tscn"),
	"wood": preload("res://effects/decals/bullet_hole_wood.tscn"),
	"metal": preload("res://effects/decals/bullet_hole_metal.tscn"),
	"stone": preload("res://effects/decals/bullet_hole_stone.tscn"),
}

## Seconds before fading out
@export var decal_lifetime: float = 30.0
## Seconds to fade out
@export var decal_fade: float = 5.0

@onready var default_decal: PackedScene = decal_scenes[decal_scenes.keys()[0]]

func spawn_decal(surface_type: String, collider: Node3D, position: Vector3, normal: Vector3) -> void:
	# Determine which decal scene to use based on surface_type (e.g. group name)
	var scene: PackedScene = decal_scenes.get(surface_type, default_decal)
	if scene == null:
		printerr("No decal available for surface type: %s" % surface_type)
		return

	# Add a new decal to the scene (as child of the collider)
	var decal = scene.instantiate()
	collider.add_child(decal)
	position_decal(decal, position, normal)

	# Set up a one-shot Timer to remove the decal after decal_lifetime seconds
	var timer = Timer.new()
	timer.wait_time = decal_lifetime
	timer.one_shot = true
	decal.add_child(timer)
	timer.timeout.connect(free_decal.bind(decal))
	timer.start()

func free_decal(decal: Node3D) -> void:
	var tween := decal.create_tween()
	tween.tween_property(decal, "modulate:a", 0, decal_fade)
	tween.tween_callback(decal.queue_free)

func position_decal(decal: Node3D, position: Vector3, normal: Vector3) -> void:
	var hit_pos := position + normal * 0.01
	decal.global_transform.origin = hit_pos
	decal.look_at(hit_pos + normal, Vector3.UP)

	# Rotate around the forward axis by a random angle for visual variety
	var random_angle = randf() * TAU  # TAU = 2*pi
	decal.rotate_object_local(Vector3.FORWARD, random_angle)
