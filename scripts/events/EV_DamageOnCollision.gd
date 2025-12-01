extends Area3D

@export var damage_amount: int = 10
@export var entity: Entity = null

func _on_body_entered(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Player):
			return  # Don't damage the player

		if body.has_component(ZC_Health):
			body.add_relationship(RelationshipUtils.make_damage(damage_amount))
			print("Applied ", damage_amount, " damage to ", body)
