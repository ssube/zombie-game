extends ZN_BaseAction
class_name ZN_SpawnAction

enum SpawnMode {
	ALL,
	RANDOM,
}

enum SpawnLocation {
	ACTOR,
	MARKER,
	SOURCE,
}

@export var spawn_scenes: Array[PackedScene] = []
@export var spawn_mode: SpawnMode = SpawnMode.RANDOM
@export var spawn_marker: Marker3D = null
@export var spawn_at: SpawnLocation = SpawnLocation.SOURCE
@export var random_radius: float = 0.0

func run_node(source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	match spawn_mode:
		SpawnMode.ALL:
			_spawn_all(actor, source)
		SpawnMode.RANDOM:
			_spawn_random(actor, source)


func _get_parent(actor: Node, source: Node) -> Node:
	match spawn_at:
		SpawnLocation.ACTOR:
			return actor
		SpawnLocation.MARKER:
			assert(spawn_marker != null, "Spawn marker must be provided for spawn actions with the marker spawn location!")
			return spawn_marker
		SpawnLocation.SOURCE:
			return source.get_parent()

	return null


func _random_offset(scene: Node) -> void:
	assert(scene is Node3D, "scene must be a 3D node to be offset!")

	var offset := Vector3(randf() * random_radius, randf() * random_radius, randf() * random_radius)
	scene.global_position += offset


func _spawn_all(actor: Node, source: Node) -> void:
	var parent := _get_parent(actor, source)
	for scene in spawn_scenes:
		_spawn_scene(scene, parent)


func _spawn_random(actor: Node, source: Node) -> void:
	var parent := _get_parent(actor, source)
	var index := randi() % spawn_scenes.size()
	var scene := spawn_scenes[index]
	_spawn_scene(scene, parent)


func _spawn_scene(scene: PackedScene, parent: Node) -> void:
	var instance := scene.instantiate()
	parent.add_child(instance)
	_random_offset(instance)

	# TODO: register nested entities with ECS world
	if instance is Entity:
		ECS.world.add_entity(instance)
		if instance is ZE_Character:
			if instance.current_weapon:
				ECS.world.add_entity(instance.current_weapon)

			if instance.inventory_node:
				for item in instance.inventory_node.get_children():
					if item is Entity:
						ECS.world.add_entity(item)
