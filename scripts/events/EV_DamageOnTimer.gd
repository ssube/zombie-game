extends Area3D

@export var active: bool = true
@export var damage_amount: int = 10
@export var damage_interval: float = 1.0
@export var damage_players: bool = false
@export var damage_enemies: bool = true

@onready var damage_timer = damage_interval

func _process(delta: float) -> void:
	if not active:
		return

	damage_timer -= delta
	if damage_timer > 0.0:
		return

	damage_timer = damage_interval
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Entity:
			apply_damage(body)

func apply_damage(body: Entity) -> void:
	if EntityUtils.is_player(body):
		if not damage_players:
			return # Don't damage the player
	else:
		if not damage_enemies:
			return # Don't damage enemies

	if EntityUtils.has_health(body):
		body.add_relationship(RelationshipUtils.make_damage(damage_amount))
		print("Applied ", damage_amount, " damage to ", body)
