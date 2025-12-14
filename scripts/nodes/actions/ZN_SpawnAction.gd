extends ZN_BaseAction
class_name ZN_SpawnAction

enum SpawnMode {
	ALL,
	RANDOM,
}

enum SpawnLocation {
	ACTOR,
	AREA,
	MARKER,
}

@export var spawn_scenes: Array[PackedScene] = []
@export var spawn_mode: SpawnMode = SpawnMode.RANDOM
@export var spawn_marker: Marker3D = null
@export var spawn_at: SpawnLocation = SpawnLocation.AREA
@export var random_radius: float = 0.0


func run_entity(actor: Entity, area: ZN_TriggerArea3D, _event: ZN_TriggerArea3D.AreaEvent) -> void:
	match spawn_mode:
		SpawnMode.ALL:
			_spawn_all(actor, area)
		SpawnMode.RANDOM:
			_spawn_random(actor, area)


func _get_parent(actor: Entity, area: ZN_TriggerArea3D) -> Node:
	match spawn_at:
		SpawnLocation.ACTOR:
			return actor
		SpawnLocation.AREA:
			return area.get_parent()
		SpawnLocation.MARKER:
			assert(spawn_marker != null, "Spawn marker must be provided for spawn actions with the marker spawn location!")
			return spawn_marker

	return null


func _random_offset(scene: Node) -> void:
	assert(scene is Node3D, "scene must be a 3D node to be offset!")

	var offset := Vector3(randf() * random_radius, randf() * random_radius, randf() * random_radius)
	scene.global_position += offset


func _spawn_all(actor: Entity, area: ZN_TriggerArea3D) -> void:
	var parent := _get_parent(actor, area)
	for scene in spawn_scenes:
		var instance := scene.instantiate()
		parent.add_child(instance)
		_random_offset(instance)


func _spawn_random(actor: Entity, area: ZN_TriggerArea3D) -> void:
	var parent := _get_parent(actor, area)
	var index := randi() % spawn_scenes.size()
	var scene := spawn_scenes[index]
	var instance := scene.instantiate()
	parent.add_child(instance)
	_random_offset(instance)
