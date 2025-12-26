extends ZN_BaseAction
class_name ZN_BehaviorBlackboardAction

enum BlackboardValue {
	ACTOR,
	SOURCE,
}

enum EntityValue {
	ID,
	POSITION,
}

@export var set_key: StringName
@export var set_value: BlackboardValue
@export var save_entity_as: EntityValue

func run_node(source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	var source_entity := CollisionUtils.get_collider_entity(source)
	var behavior := source_entity.get_component(ZC_Behavior) as ZC_Behavior

	match set_value:
		BlackboardValue.ACTOR:
			var value = _get_entity_value(actor)
			behavior.set_value(set_key, value)
		BlackboardValue.SOURCE:
			var value = _get_entity_value(source)
			behavior.set_value(set_key, value)

func _get_entity_value(actor: Node) -> Variant:
	if actor is not Entity:
		return actor # TODO: is this right?

	var entity := actor as Entity
	match save_entity_as:
		EntityValue.ID:
			return entity.id
		EntityValue.POSITION:
			return entity.global_position

	return null
