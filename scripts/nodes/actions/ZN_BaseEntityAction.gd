extends ZN_BaseAction
class_name ZN_BaseEntityAction

func run_node(_source: Node, _event: Enums.ActionEvent, _actor: Node) -> void:
	pass

func run_physics(_source: Node, _event: Enums.ActionEvent, _actor: PhysicsBody3D) -> void:
	pass

## Check condition children before running
func test(source: Node, event: Enums.ActionEvent, actor: Node) -> bool:
	if actor is not Entity:
		return false

	return super.test(source, event, actor)
