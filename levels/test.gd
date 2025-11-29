extends RigidBody3D

func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	axis_lock_angular_x = true
	axis_lock_angular_z = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = Vector3(1, state.linear_velocity.y, 0)
	
	print("Contact count: ", state.get_contact_count())
	for i in state.get_contact_count():
		print("  Contact ", i, ": ", state.get_contact_collider(i), " normal: ", state.get_contact_local_normal(i))
	
	print("Pos: ", state.transform.origin, " | Vel: ", state.linear_velocity)
