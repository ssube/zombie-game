extends Area3D


@export var require_line_of_sight: bool = true

var body_queue: Array[Node] = []
var sight_queue: Array[Node] = []


func _on_body_entered(body: Node) -> void:
	if require_line_of_sight:
		if body not in body_queue:
			body_queue.append(body)
	else:
		# skip line of sight check, append directly to sight queue
		if body not in sight_queue:
			sight_queue.append(body)


func _physics_process(_delta: float) -> void:
	if not require_line_of_sight:
		return

	var space_state := get_world_3d().direct_space_state
	var root_pos := self.global_position

	for body in body_queue:
		if body is Node3D:
			var query := PhysicsRayQueryParameters3D.create(root_pos, body.global_position)
			var result := space_state.intersect_ray(query)
			var collider = result.get("collider")
			if collider == null:
				continue

			print("Colliding with: ", collider)
			if collider == body:
				# TODO: handle child
				sight_queue.append(body)

	body_queue.clear()


func _process(_delta: float) -> void:
	for body in sight_queue:
		apply_effects(body)

	sight_queue.clear()


func apply_effects(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Flammable):
			var fire := ZC_Effect_Burning.new()
			body.add_component(fire)
			print("Fire spread to: ", body)

	if body is RigidBody3D:
		var force = body.mass / 5.0
		body.apply_impulse(Vector3(0, force, 0), self.global_position)