extends ZN_BaseAction
class_name ZN_StaminaAction

@export var change_stamina: bool = false
@export var change_amount: float = 0.0
@export var disable_recharge: bool = true

func run_entity(_source: Node, event: Enums.ActionEvent, actor: Entity) -> void:
	var stamina := actor.get_component(ZC_Stamina) as ZC_Stamina
	if stamina == null:
		return

	if change_stamina:
		stamina.current_stamina += change_amount

	match event:
		Enums.ActionEvent.BODY_ENTER:
			if disable_recharge:
				# TODO: this needs to be controlled by a relationship so that multiple sources can disable recharge
				stamina.recharge_disabled = true
		Enums.ActionEvent.BODY_EXIT:
			if disable_recharge:
				stamina.recharge_disabled = false
