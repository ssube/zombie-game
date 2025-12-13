class_name DialogueUtils

static func look_at_position(entity: Entity, position: Vector3) -> void:
	var movement := entity.get_component(ZC_Movement) as ZC_Movement
	movement.target_look_position = position

static func look_at_entity(entity: Entity, target: Entity) -> void:
	var target3d := target.get_node(".") as Node3D
	look_at_node(entity, target3d)

static func look_at_offset(entity: Entity, offset: Vector3) -> void:
	var entity3d := entity.get_node(".") as Node3D
	var position := entity3d.global_position + offset
	look_at_position(entity, position)

static func look_at_marker(entity: Entity, marker: Marker3D) -> void:
	look_at_node(entity, marker)

static func look_at_node(entity: Entity, node: Node3D) -> void:
	look_at_position(entity, node.global_position)

class DialogueHelper:
	var entity: Entity
	var markers: Dictionary[String, Marker3D]

	func _init(target_entity: Entity, level_markers: Dictionary[String, Marker3D]) -> void:
		entity = target_entity
		markers = level_markers

	func look_at_position(position: Vector3) -> void:
		DialogueUtils.look_at_position(entity, position)

	func look_at_entity(target: Entity) -> void:
		DialogueUtils.look_at_entity(entity, target)

	func look_at_offset(offset: Vector3) -> void:
		DialogueUtils.look_at_offset(entity, offset)

	func look_at_marker(marker_name: String) -> void:
		var marker_node := markers.get(marker_name) as Marker3D
		DialogueUtils.look_at_node(entity, marker_node)

	func look_at_node(node: Node3D) -> void:
		DialogueUtils.look_at_node(entity, node)
