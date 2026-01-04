extends ZN_BaseCondition
class_name ZN_ConsumableCondition

enum ConsumableCheck {
	HAS_USES,
	NO_USES,
}

@export var check: ConsumableCheck = ConsumableCheck.HAS_USES
@export var min_uses: int = 1

func test(_source: Node, _event: Enums.ActionEvent, actor: Node) -> bool:
	var consumable := actor.get_component(ZC_Consumable) as ZC_Consumable
	if consumable == null:
		return false

	match check:
		ConsumableCheck.HAS_USES:
			return consumable.current_uses >= min_uses
		ConsumableCheck.NO_USES:
			return consumable.current_uses == 0

	return false
