extends System
class_name ZS_StaminaSystem


@export var effect_interval: float = 0.5
var _effect_delta: float = 0.0

@onready var remove_query = Relationship.new(
	ZC_Effected.new(),
	{
		ZC_Screen_Effect: {
			"effect": {
				"_eq": ZM_BaseMenu.Effects.VIGNETTE,
			},
		}
	}
)


func _ready() -> void:
	var game := TreeUtils.get_game(self)
	game.level_loaded.connect(_on_level_loaded)


func query() -> QueryBuilder:
	return q.with_all([ZC_Stamina])


func _on_level_loaded(_old_level: String, _new_level: String) -> void:
	var players := EntityUtils.get_players()
	for player in players:
		var stamina := player.get_component(ZC_Stamina) as ZC_Stamina
		if stamina == null:
			continue

		_update_effects(player, stamina)


func _should_update_effects(delta: float) -> bool:
	_effect_delta += delta
	if _effect_delta >= effect_interval:
		_effect_delta = 0.0
		return true

	return false


func _update_effects(entity: Entity, stamina: ZC_Stamina) -> void:
	var inv_stamina_ratio := 1.0 - (stamina.current_stamina / stamina.max_stamina)
	var effect := ZC_Screen_Effect.new()
	effect.effect = ZM_BaseMenu.Effects.VIGNETTE
	effect.strength = lerpf(-0.1, 0.7, clampf(inv_stamina_ratio, 0.0, 0.8))
	effect.strength = clampf(effect.strength, 0.0, 1.0)
	effect.duration = 5.0

	entity.remove_relationship(remove_query, 1)
	entity.add_relationship(RelationshipUtils.make_effect(effect))


func _get_body_velocity(entity: Entity) -> Vector3:
	var node := entity as Node
	if node is RigidBody3D:
		var physics_body := node as RigidBody3D
		return physics_body.linear_velocity

	if node is CharacterBody3D:
		var character_body := node as CharacterBody3D
		return character_body.velocity

	if entity.has_component(ZC_Velocity):
		var c_velocity := entity.get_component(ZC_Velocity) as ZC_Velocity
		return c_velocity.velocity

	return Vector3.ZERO


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	var should_update_effects := _should_update_effects(delta)

	for entity in entities:
		var stamina := entity.get_component(ZC_Stamina) as ZC_Stamina
		if stamina.current_stamina >= stamina.max_stamina:
			continue

		# Only recharge if they are still
		var velocity := _get_body_velocity(entity)

		var recharge: float = 0.0
		if is_zero_approx(velocity.linear_velocity.length_squared()):
			recharge += stamina.still_recharge_rate
		else:
			recharge += stamina.moving_recharge_rate

		# Apply cost
		var input := entity.get_component(ZC_Input) as ZC_Input
		var cost: float = velocity.linear_velocity.length() * stamina.velocity_multiplier
		if input and input.move_sprint:
			cost *= stamina.sprint_multiplier

		var change := (recharge - cost) * delta
		stamina.current_stamina += change

		if EntityUtils.is_player(entity):
			%Menu.set_stamina(stamina.current_stamina)

			# update once per second or so
			if should_update_effects:
				_update_effects(entity, stamina)
