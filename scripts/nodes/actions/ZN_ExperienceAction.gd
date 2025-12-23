extends ZN_BaseAction
class_name ZN_ExperienceAction


func run_entity(source: Node, _event: Enums.ActionEvent, actor: Entity) -> void:
	if source is not Entity:
		return

	var source_experience := source.get_component(ZC_Experience) as ZC_Experience
	if source_experience == null:
		return

	var actor_experience := actor.get_component(ZC_Experience) as ZC_Experience
	if actor_experience == null:
		return

	var transfer := source_experience.get_transfer_xp()
	actor_experience.earned_xp += transfer
	source_experience.clear()
