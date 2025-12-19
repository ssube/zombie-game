extends ZN_BaseAction
class_name ZN_ScreenEffectAction


@export var effect: ZC_Screen_Effect

@onready var remove_query = Relationship.new(
	ZC_Effected.new(),
	{
		ZC_Screen_Effect: {
			"effect": {
				"_eq": effect.effect,
			},
			"strength": {
				"_eq": effect.strength,
			},
		}
	}
)


func _apply_effect(body: Node) -> void:
	if body.has_component(ZC_Player):
		var body_effect := effect.duplicate()
		body.add_relationship(RelationshipUtils.make_effect(body_effect))


func _remove_effect(body: Node) -> void:
	if body.has_component(ZC_Player):
		body.remove_relationship(remove_query)


func run_entity(_source: Node, event: Enums.ActionEvent, actor: Entity) -> void:
	match event:
		Enums.ActionEvent.BODY_ENTER:
			_apply_effect(actor)
		Enums.ActionEvent.BODY_EXIT:
			_remove_effect(actor)
