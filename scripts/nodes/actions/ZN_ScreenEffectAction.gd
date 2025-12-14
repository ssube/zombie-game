extends ZN_BaseAction
class_name ZN_ScreenEffectAction


@export var effect: ZC_Screen_Effect


func _apply_effect(body: Node) -> void:
	if body.has_component(ZC_Player):
		var body_effect := effect.duplicate()
		body.add_relationship(RelationshipUtils.make_effect(body_effect))


func _remove_effect(body: Node) -> void:
	if body.has_component(ZC_Player):
		var body_effect := effect.duplicate()
		body_effect.strength = 0.0
		body.add_relationship(RelationshipUtils.make_effect(body_effect))

		# TODO: removing the relationship here does nothing, because the player system
		# already removes it when applying the screen effect to the menu. there should
		# be some separation of concerns, maybe an effect system as its own class.
		# body.remove_relationship(RelationshipUtils.make_effect(body_effect))


func run(actor: Entity, _area: ZN_TriggerArea3D, event: ZN_TriggerArea3D.AreaEvent) -> void:
	match event:
		ZN_TriggerArea3D.AreaEvent.BODY_ENTER:
			_apply_effect(actor)
		ZN_TriggerArea3D.AreaEvent.BODY_EXIT:
			_remove_effect(actor)
