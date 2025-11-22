class_name ZS_MovementSystem
extends System

func query():
	return q.with_all([ZC_Transform, ZC_Velocity]).with_none([ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, _delta: float):
	for entity in entities:
		if entity == null:
			printerr("Stepping null entity: ", entity)
			continue
			
		if entity.is_queued_for_deletion() or not entity.is_inside_tree():
			continue

		var transform = entity.get_component(ZC_Transform) as ZC_Transform
		var body := entity.get_node(".") as RigidBody3D

		if body:
			transform.position = body.global_position
			transform.rotation = body.rotation
