@tool
extends ZE_Base
class_name ZE_Player

@export var weapon: ZE_Weapon = null

func on_ready():
	sync_health()
	sync_transform()


## Sync health from component to menu
func sync_health():
	var c_health = get_component(ZC_Health) as ZC_Health
	if not c_health:
		return

	%Hud.set_health(c_health.current_health, true)


## Sync transform from scene to component
func sync_transform():
	var c_trs = get_component(ZC_Transform) as ZC_Transform
	if not c_trs:
		return

	var root := self.get_node(".") as Node3D
	c_trs.position = root.global_position
	c_trs.rotation = root.global_rotation
