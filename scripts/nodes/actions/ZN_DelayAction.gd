extends ZN_BaseAction
class_name ZN_DelayAction

@export var delay: float = 5.0

var timer: SceneTreeTimer

func run_node(_source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	timer = self.get_tree().create_timer(delay)
	timer.timeout.connect(run_children.bind(actor))


func run_children(actor: Entity) -> void:
	var children := self.get_children()
	for child in children:
		if child is ZN_BaseAction:
			child.run(actor)
