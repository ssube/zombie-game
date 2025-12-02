extends Area3D

@export var damage_amount: int = 10
@export var damage_players: bool = false
@export var damage_enemies: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Entity:
		if body.has_component(ZC_Player):
			if not damage_players:
				return # Don't damage the player
		else:
			if not damage_enemies:
				return # Don't damage enemies

		if body.has_component(ZC_Health):
			body.add_relationship(RelationshipUtils.make_damage(damage_amount))
			print("Applied ", damage_amount, " damage to ", body)
