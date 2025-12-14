extends ZN_BaseAction
class_name ZN_SpawnAction

enum SpawnMode {
	ALL,
	RANDOM,
}

enum SpawnLocation {
	ACTOR,
	MARKER,
	SPAWNER,
}

@export var spawn_scenes: Array[PackedScene] = []
@export var spawn_mode: SpawnMode = SpawnMode.RANDOM
@export var spawn_marker: Marker3D = null
@export var spawn_at: SpawnLocation = SpawnLocation.SPAWNER
@export var random_radius: float = 0.0


func run(actor: Entity) -> void:
	match spawn_mode:
		SpawnMode.ALL:
			_spawn_all(actor)
		SpawnMode.RANDOM:
			_spawn_random(actor)


func _get_parent(actor: Entity) -> Node:
	match spawn_at:
		SpawnLocation.ACTOR:
			return actor
		SpawnLocation.MARKER:
			return spawn_marker
		SpawnLocation.SPAWNER:
			return self.get_parent()

	return null


func _random_offset(scene: Node) -> void:
	assert(scene is Node3D, "scene must be a 3D node to be offset!")

	var offset := Vector3(randf() * random_radius, randf() * random_radius, randf() * random_radius)
	scene.global_position += offset


func _spawn_all(actor: Entity) -> void:
	var parent := _get_parent(actor)
	for scene in spawn_scenes:
		var instance := scene.instantiate()
		parent.add_child(instance)
		_random_offset(instance)


func _spawn_random(actor: Entity) -> void:
	var parent := _get_parent(actor)
	var index := randi() % spawn_scenes.size()
	var scene := spawn_scenes[index]
	var instance := scene.instantiate()
	parent.add_child(instance)
	_random_offset(instance)
