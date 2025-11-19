extends Area3D


func _on_body_entered(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Flammable):
			var fire := ZC_Effect_Burning.new()
			body.add_component(fire)
			print("Fire spread to: ", body)

	if body is RigidBody3D:
		var force = body.mass / 5.0
		body.apply_impulse(Vector3(0, force, 0), self.global_position)