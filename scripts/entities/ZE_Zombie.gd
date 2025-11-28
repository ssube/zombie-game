@tool
extends ZE_Base
class_name ZE_Zombie

func on_ready():
	# Sync transform from scene to component
	var c_trs = get_component(ZC_Transform) as ZC_Transform
	if not c_trs:
		return

	var root := self.get_node(".") as Node3D
	c_trs.position = root.global_position
	c_trs.rotation = root.global_rotation
