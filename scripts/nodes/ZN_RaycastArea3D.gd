extends ZN_TriggerArea3D
class_name ZN_RaycastArea3D


var body_queue: Array[Node] = []
var sight_queue: Array[Node] = []


func _on_body_entered(body: Node) -> void:
	if body not in body_queue:
		body_queue.append(body)


func _physics_process(_delta: float) -> void:
	var space_state := get_world_3d().direct_space_state
	var root_pos := self.global_position

	for body in body_queue:
		if body is Node3D:
			var query := PhysicsRayQueryParameters3D.create(root_pos, body.global_position)
			var result := space_state.intersect_ray(query)
			var collider = result.get("collider")
			if collider == null:
				continue

			print("Area is colliding with: ", collider)
			if collider == body:
				sight_queue.append(body)

	body_queue.clear()


func _process(delta: float) -> void:
	super._process(delta)

	for body in sight_queue:
		apply_actions(body, self, AreaEvent.BODY_ENTER)

	sight_queue.clear()
