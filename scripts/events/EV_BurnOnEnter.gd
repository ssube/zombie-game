extends Area3D


func _on_body_entered(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Flammable):
			var fire := ZC_Effect_Burning.new()
			body.add_component(fire)
			print("Fire spread to: ", body)
