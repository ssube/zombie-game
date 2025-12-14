extends ZN_BaseAction
class_name ZN_FireAction

enum FireMode {
	EXTEND,
	EXTINGUISH,
	IGNITE,
}

@export var fire_mode: FireMode = FireMode.IGNITE
@export var fire_duration: float = 5.0

func run(actor: Entity) -> void:
	match fire_mode:
		FireMode.EXTEND:
			if actor.has_component(ZC_Effect_Burning):
				var burning := actor.get_component(ZC_Effect_Burning) as ZC_Effect_Burning
				burning.time_remaining = fire_duration
		FireMode.EXTINGUISH:
			actor.remove_component(ZC_Effect_Burning.new())
		FireMode.IGNITE:
			actor.add_component(ZC_Effect_Burning.new(fire_duration))
