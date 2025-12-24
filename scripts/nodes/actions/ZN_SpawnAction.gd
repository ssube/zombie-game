extends ZN_BaseAction
class_name ZN_SpawnAction

enum SpawnMode {
	ALL,
	RANDOM,
}

enum SpawnPosition {
	ACTOR,
	MARKER,
	SOURCE,
}

enum SpawnParent {
	ACTOR,
	ACTOR_PARENT,
	SOURCE,
	SOURCE_PARENT,
}

@export var spawn_mode: SpawnMode = SpawnMode.RANDOM
@export var spawn_parent: SpawnParent = SpawnParent.SOURCE_PARENT
@export var spawn_position: SpawnPosition = SpawnPosition.SOURCE
@export var spawn_scenes: Array[PackedScene] = []
@export var spawn_marker: Marker3D = null
@export var random_spread: Vector3 = Vector3.ZERO
@export var snap_to_nav_mesh: bool = true


func run_node(source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	match spawn_mode:
		SpawnMode.ALL:
			_spawn_all(actor, source)
		SpawnMode.RANDOM:
			_spawn_random(actor, source)


func _get_parent(actor: Node, source: Node) -> Node:
	match spawn_parent:
		SpawnParent.ACTOR:
			return actor
		SpawnParent.ACTOR_PARENT:
			return actor.get_parent()
		SpawnParent.SOURCE:
			return source
		SpawnParent.SOURCE_PARENT:
			return source.get_parent()

	return null


func _get_position(actor: Node, source: Node) -> Vector3:
	var node: Node3D

	match spawn_position:
		SpawnPosition.ACTOR:
			node = actor
		SpawnPosition.MARKER:
			assert(spawn_marker != null, "Spawn marker must be provided for spawn actions with the marker spawn location!")
			node = spawn_marker
		SpawnPosition.SOURCE:
			node = source

	return node.global_position


func _random_offset(node: Node3D) -> Vector3:
	assert(node is Node3D, "scene must be a 3D node to be offset!")

	# TODO: spread both positive and negative direction
	var offset := Vector3(randf() * random_spread.x, randf() * random_spread.y, randf() * random_spread.z)
	return offset


func _snap_to_nav_mesh(node: Node3D, position: Vector3) -> Vector3:
	var default_map_rid: RID = node.get_world_3d().get_navigation_map()

	return NavigationServer3D.map_get_closest_point(
		default_map_rid,
		position
	)


func _spawn_all(actor: Node, source: Node) -> void:
	var parent := _get_parent(actor, source)
	var position := _get_position(actor, source)

	for scene in spawn_scenes:
		_spawn_scene(scene, parent, position)


func _spawn_random(actor: Node, source: Node) -> void:
	var parent := _get_parent(actor, source)
	var position := _get_position(actor, source)

	var index := randi() % spawn_scenes.size()
	var scene := spawn_scenes[index]
	_spawn_scene(scene, parent, position)


func _spawn_scene(scene: PackedScene, parent: Node, position: Vector3) -> void:
	var instance := scene.instantiate()
	parent.add_child(instance)

	instance.global_position = position

	if not is_zero_approx(random_spread.length_squared()):
		instance.global_position += _random_offset(instance)

	if snap_to_nav_mesh:
		instance.global_position = _snap_to_nav_mesh(instance, instance.global_position)

	if instance is Entity:
		ECS.world.add_entity(instance)
