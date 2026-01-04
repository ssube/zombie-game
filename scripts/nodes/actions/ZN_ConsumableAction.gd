extends ZN_BaseAction
class_name ZN_ConsumableAction


enum ConsumableMode {
	USE,
	REFILL,
	SET,
}

enum ConsumableTarget {
	ACTOR,
	SOURCE,
}


@export var amount: int = 1
@export var mode: ConsumableMode = ConsumableMode.USE
@export var target: ConsumableTarget = ConsumableTarget.ACTOR


func _get_target(actor: Node, source: Node) -> Entity:
	match target:
		ConsumableTarget.ACTOR:
			return actor
		ConsumableTarget.SOURCE:
			return source

	return null


func run_node(source: Node, _event: Enums.ActionEvent, actor: Node) -> void:
	var target_entity := _get_target(actor, source)
	if target_entity == null:
		return

	var consumable := target_entity.get_component(ZC_Consumable) as ZC_Consumable
	if consumable == null:
		return

	match mode:
		ConsumableMode.USE:
			consumable.current_durability -= amount
		ConsumableMode.REFILL:
			consumable.current_durability += amount
		ConsumableMode.SET:
			consumable.current_durability = amount
