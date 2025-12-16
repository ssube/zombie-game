extends ZN_BaseAction
class_name ZN_BaseEntityAction

## Check condition children before running
func test(source: Node, event: Enums.ActionEvent, actor: Node) -> bool:
	if actor is not Entity:
		return false

	return super.test(source, event, actor)
