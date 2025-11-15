class_name ZS_MovementSystem
extends System

func query():
	return q.with_all([ZC_Transform, ZC_Velocity]).with_none([ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		var transform = entity.get_component(ZC_Transform) as ZC_Transform
		var body := entity.get_node(".") as RigidBody3D

		if body:
			transform.position = body.global_position
			transform.rotation = body.rotation
