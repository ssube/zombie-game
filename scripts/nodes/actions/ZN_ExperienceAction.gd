extends ZN_BaseAction
class_name ZN_ExperienceAction

@export var experience: ZC_Experience

func run_entity(_source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	var actor_experience := actor.get_component(ZC_Experience) as ZC_Experience
	if actor_experience == null:
		return

	var transfer := experience.get_transfer_xp()
	actor_experience.earned_xp += transfer
