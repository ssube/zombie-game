extends ZB_Condition
class_name ZB_IsPlayerVisible

@export var vision_cone: Area3D = null

func test(actor: Node, _delta: float, blackboard: ZB_Blackboard) -> bool:
	if ECS.world == null:
		return false

	if not actor.is_inside_tree():
		return false

	var visible: Array = []
	if vision_cone is VisionCone3D:
		visible = vision_cone.get_visible_bodies()
	else:
		vision_cone.get_overlapping_bodies()

	for body: Node3D in visible:
		var body_root = body.get_node(".")
		if body_root is Entity:
			if body_root.has_component(ZC_Player):
				blackboard.set_value("visible_player", body)
				# blackboard.set_value("target_player", body)
				# blackboard.set_value("target_position", body.global_position)
				return true

	return false
