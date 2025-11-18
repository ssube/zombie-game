extends Observer
class_name ZO_HudObserver

func watch() -> Resource:
	return ZC_Health

func match():
	return q.with_all([ZC_Health, ZC_Player])

func on_component_changed(_entity: Entity, _component: Resource, property: String, new_value: Variant, old_value: Variant):
	print("health changed: ", property, new_value, old_value)
	if new_value != old_value:
		call_deferred("update_hud", new_value)

func update_hud(health: int) -> void:
	%Hud.set_health(health)
