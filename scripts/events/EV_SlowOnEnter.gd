extends Area3D

@export var speed_modifier: float = 0.5

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Velocity):
			print("Slowing entity: ", body)
			var vel_comp: ZC_Velocity = body.get_component(ZC_Velocity)
			vel_comp.speed_modifier *= speed_modifier

func _on_body_exited(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Velocity):
			print("Restoring entity speed: ", body)
			var vel_comp: ZC_Velocity = body.get_component(ZC_Velocity)
			vel_comp.speed_modifier /= speed_modifier