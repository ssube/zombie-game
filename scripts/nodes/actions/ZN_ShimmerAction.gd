extends ZN_BaseAction
class_name ZN_ShimmerAction


enum ShimmerTarget {
	## Enable or disable shimmer on the actor entity
	ACTOR,
	## Enable or disable shimmer on the source entity
	SOURCE,
	## Another entity specified in the action
	OTHER,
}


@export var enable_shimmer: Enums.Tristate = Enums.Tristate.TRUE
@export var target: ShimmerTarget = ShimmerTarget.ACTOR
@export var entity: Entity = null


func _get_entity(source: Node, actor: Entity) -> Entity:
	match target:
		ShimmerTarget.ACTOR:
			return actor
		ShimmerTarget.SOURCE:
			return CollisionUtils.get_collider_entity(source)
		ShimmerTarget.OTHER:
			return entity
	return null


func run_entity(source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var target_entity := _get_entity(source, actor)
	if target_entity == null:
		return

	var shimmer_component := target_entity.get_component(ZC_Shimmer) as ZC_Shimmer
	if shimmer_component == null:
		return

	match enable_shimmer:
		Enums.Tristate.TRUE:
			shimmer_component.enabled = true
		Enums.Tristate.FALSE:
			shimmer_component.enabled = false
