class_name ZS_MovementSystem
extends System

func query():
	# Find all entities that have both transform and velocity
	return q.with_all([ZC_Transform, ZC_Velocity]).with_none([ZC_Player, ZC_Input])

func process(entities: Array[Entity], _components: Array, delta: float):
	# Process each entity in the array
	for entity in entities:
		var c_trs = entity.get_component(ZC_Transform) as ZC_Transform
		var c_velocity = entity.get_component(ZC_Velocity) as ZC_Velocity

		# Move the entity based on its velocity
		c_trs.position += c_velocity.linear_velocity * delta

		# Update the actual entity position in the scene
		entity.global_position = c_trs.position

		# Bounce off screen edges (simple example)
		if c_trs.position.x > 10 or c_trs.position.x < -10:
			c_velocity.linear_velocity.x *= -1
