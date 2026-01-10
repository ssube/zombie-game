@tool
extends ZE_Character
class_name ZE_Player


## Tracks the last entity this player looked at for shimmer effect management
var last_shimmer_target: Entity = null


func on_ready():
	super.on_ready()
	sync_experience()
	sync_health()
	sync_stamina()


func sync_experience():
	var c_experience := get_component(ZC_Experience) as ZC_Experience
	if not c_experience:
		return

	%Menu.set_score(c_experience.total_xp)


## Sync health from component to menu
func sync_health():
	var c_health := get_component(ZC_Health) as ZC_Health
	if not c_health:
		return

	%Menu.set_health(c_health.current_health, true)


func sync_stamina():
	var c_stamina := get_component(ZC_Stamina) as ZC_Stamina
	if not c_stamina:
		return

	%Menu.set_stamina(c_stamina.current_stamina, true)
