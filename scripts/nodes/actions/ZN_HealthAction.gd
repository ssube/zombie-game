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


func run_entity(source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var actor_health := actor.get_component(ZC_Health) as ZC_Health
	if actor_health == null:
		return

	# Get the parent entity. If the entity exists, check if someone is wielding it.
	# Attribute the damage to the entity furthest up the chain.
	var source_entity := CollisionUtils.get_collider_entity(source)
	if source_entity:
		var source_wielder := RelationshipUtils.get_wielder(source_entity)
		if source_wielder != null:
			source_entity = source_wielder

	match health_mode:
		HealthMode.DAMAGE:
			actor.add_relationship(RelationshipUtils.make_damage(source_entity, health_amount))
		HealthMode.HEAL:
			actor.add_relationship(RelationshipUtils.make_damage(source_entity, -health_amount))
		HealthMode.MAX:
			assert(false, "TODO: implement max health action")
			# actor_health.current_health = maxi(actor_health.current_health, health_amount)
		HealthMode.SET:
			assert(false, "TODO: implement set health action")
			# actor_health.current_health = health_amount
