extends ZN_BaseAction
class_name ZN_BehaviorBlackboardAction

enum BlackboardValue {
	ACTOR,
	SOURCE,
}

@export var blackboard: ZB_Blackboard
@export var set_key: StringName
@export var set_value: BlackboardValue

func run_node(source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	match set_value:
		BlackboardValue.ACTOR:
			blackboard.set_value(set_key, actor)
		BlackboardValue.SOURCE:
			blackboard.set_value(set_key, source)
