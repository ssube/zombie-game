extends Area3D

@export var active: bool = true
@export var burn_interval: float = 1.0
@export var damage_players: bool = false
@export var damage_enemies: bool = true

@onready var burn_timer = burn_interval

func _process(delta: float) -> void:
	if not active:
		return

	burn_timer -= delta
	if burn_timer > 0.0:
		return

	burn_timer = burn_interval
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Entity:
			apply_damage(body)

func apply_damage(body: Entity) -> void:
	if body.has_component(ZC_Player):
		if not damage_players:
			return # Don't damage the player
	else:
		if not damage_enemies:
			return # Don't damage enemies

	if body.has_component(ZC_Flammable):
		var fire := ZC_Effect_Burning.new()
		body.add_component(fire)
		print("Fire spread to: ", body)
