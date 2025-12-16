extends ZN_BaseAction
class_name ZN_HealthAction

enum HealthMode {
	## Health will be removed
	DAMAGE,
	## Health will be added
	HEAL,
	## Health will be set to at least this value, increasing it but never decreasing it
	MAX,
	## Health will be set to this exact value, increasing or decreasing it
	SET,
}

@export var health_mode: HealthMode = HealthMode.HEAL
@export var health_amount: int = 10


func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var actor_health := actor.get_component(ZC_Health) as ZC_Health
	if actor_health == null:
		return

	match health_mode:
		HealthMode.DAMAGE:
			actor.add_relationship(RelationshipUtils.make_damage(health_amount))
		HealthMode.HEAL:
			actor.add_relationship(RelationshipUtils.make_damage(-health_amount))
		HealthMode.MAX:
			actor_health.current_health = maxi(actor_health.current_health, health_amount)
		HealthMode.SET:
			actor_health.current_health = health_amount
