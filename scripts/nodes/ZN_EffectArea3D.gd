extends Area3D

@export var effect: ZC_Screen_Effect

func _apply_effect(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Player):
			var body_effect := effect.duplicate()
			body.add_relationship(RelationshipUtils.make_effect(body_effect))

func _remove_effect(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Player):
			var body_effect := effect.duplicate()
			body_effect.strength = 0.0
			body.add_relationship(RelationshipUtils.make_effect(body_effect))

			# TODO: removing the relationship here does nothing, because the player system
			# already removes it when applying the screen effect to the menu. there should
			# be some separation of concerns, maybe an effect system as its own class.
			# body.remove_relationship(RelationshipUtils.make_effect(body_effect))

func _ready() -> void:
	body_entered.connect(_apply_effect)
	body_exited.connect(_remove_effect)
