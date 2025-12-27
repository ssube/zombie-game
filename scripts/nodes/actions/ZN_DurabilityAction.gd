extends ZN_BaseAction
class_name ZN_DurabilityAction

enum DurabilityMode {
	ADD,
	MAX,
	REMOVE,
	SET,
}

enum DurabilityTarget {
	ACTOR,
	ACTOR_ARMOR,
	ACTOR_WEAPON,
	ENTITY,
}

@export var default_amount: int = 10
@export var surface_amounts: Dictionary[String, int] = {}
@export var entity: Entity = null
@export var mode: DurabilityMode = DurabilityMode.REMOVE
@export var target: DurabilityTarget = DurabilityTarget.ENTITY


func _get_target(actor: Node) -> Entity:
	match target:
		DurabilityTarget.ACTOR:
			return actor
		DurabilityTarget.ACTOR_ARMOR:
			assert(false, "TODO: Actor armor target not implemented!")
		DurabilityTarget.ACTOR_WEAPON:
			assert(false, "TODO: Actor weapon target not implemented!")
		DurabilityTarget.ENTITY:
			assert(entity != null, "Entity must be provided for entity target!")
			return entity

	return null


func run_node(_source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	var target_entity := _get_target(actor)
	if target_entity == null:
		return

	var durability := target_entity.get_component(ZC_Durability) as ZC_Durability
	if durability == null:
		return

	var surface_type := CollisionUtils.get_body_surface(actor as Node)
	var amount := surface_amounts.get(surface_type, default_amount) as int

	match mode:
		DurabilityMode.ADD:
			durability.current_durability += amount
		DurabilityMode.MAX:
			durability.current_durability = max(durability.current_durability, amount)
		DurabilityMode.REMOVE:
			durability.current_durability -= amount
		DurabilityMode.SET:
			durability.current_durability = amount
